# library(testthat); library(parallelRemake); 
context("remake_args")
source("utils.R")

test_that("Function remake_args behaves correctly.", {
  expect_equal(
    remake_args(list(hi = 1, remake_file = 12, target_names = 15, 
      x = 5, verbose = TRUE, file = "this file")),
    ", hi = 1, x = 5, verbose = TRUE, file = \"this file\"")
  expect_equal(remake_args(list(remake_file = 12, target_names = 15)), "")
  expect_equal(remake_args(list()), "")
  expect_error(remake_args(list(1, zero = 5)))
  expect_error(remake_args())
  expect_error(remake_args("file"))
  expect_error(remake_args("file1", "file2"))
  expect_error(remake_args(c("file1", "file2")))
  expect_error(remake_args(list("file")))
  expect_error(remake_args(list("file1", "file2")))
})

test_that("Correct Makefiles are made with remake_args.", {
  example_source_file()
  example_remake_file()
  write_makefile()
  expect_equal(readLines("Makefile")[-1], readLines("test-remake_args/Makefile1")[-1])
  write_makefile(remake_args = list(verbose = F, string = "my string"), 
    clean = "rm -rf myfile", begin = "#begin", makefile = "testmake")
  expect_equal(readLines("testmake")[-1], readLines("test-remake_args/Makefile2")[-1])
  out = system("make -f testmake 2>&1", intern = T)
  expect_equal(out, readLines("test-remake_args/output.txt"))
  expect_true(all(recallable() == paste0("processed", 1:2)))
  expect_true(all(recall("processed1")[,2:12] == mtcars))
  expect_true(all(recall("processed2")[,2:12] == mtcars))
  files = c("code.R", "data.csv", "Makefile", "testmake", "plot1.pdf", "plot2.pdf", "remake.yml")
  expect_true(all(files %in% list.files()))
  cleanup(files)
})