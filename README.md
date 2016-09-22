# parallelRemake

[![Travis-CI Build Status](https://travis-ci.org/wlandau/parallelRemake.svg?branch=master)](https://travis-ci.org/wlandau/parallelRemake)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/wlandau/parallelRemake?branch=master&svg=true)](https://ci.appveyor.com/project/wlandau/parallelRemake)
[![codecov.io](https://codecov.io/github/wlandau/parallelRemake/coverage.svg?branch=master)](https://codecov.io/github/wlandau/parallelRemake?branch=master)

The `parallelRemake` package is a helper add-on for [`remake`](https://github.com/richfitz/remake), a [Makefile](https://www.gnu.org/software/make/)-like reproducible build system for R. If you haven't done so already, go learn [`remake`](https://github.com/richfitz/remake)! Also learn [GNU make](https://www.gnu.org/software/make/), and then recall that `make -j 4` runs a [Makefile](https://www.gnu.org/software/make/) while distributing the rules over four parallel processes. This mode of parallelism is the whole point of `parallelRemake`. With `parallelRemake`, you can write an overarching [Makefile](https://www.gnu.org/software/make/) for a [`remake`](https://github.com/richfitz/remake) project to run [`remake`](https://github.com/richfitz/remake) targets in parallel. This distributed parallelism is extremely helpful for large clusters that use the [Slurm job scheduler](http://slurm.schedmd.com/), for example, as explained in [this post](http://plindenbaum.blogspot.com/2014/09/parallelizing-gnu-make-4-in-slurm.html).

# Installation

Ensure that [R](https://www.r-project.org/) is installed, as well as the dependencies in the [`DESCRIPTION`](https://github.com/wlandau/parallelRemake/blob/master/DESCRIPTION). Then, you can install one of the [stable releases](https://github.com/wlandau/parallelRemake/releases). Download `parallelRemake_<VERSION>.tar.gz` (where `<VERSION>` is the version number), open an R session, and run the following.

```r
install.packages("parallelRemake_<VERSION>.tar.gz", repos = NULL, type = "source")
```

To install the development version, get the [devtools](https://cran.r-project.org/web/packages/devtools/) package and then run

```
devtools::install_github("wlandau/parallelRemake")
```

# Rtools for Windows users

The example and tests sometimes use `system("make")` and similar commands. So if you're using the Windows operating system, you will need to install the [`Rtools`](https://github.com/stan-dev/rstan/wiki/Install-Rtools-for-Windows) package.

# Help and troubleshooting

Use the `help_parallelRemake()` function to obtain a collection of helpful links. For troubleshooting, please refer to [TROUBLESHOOTING.md](https://github.com/wlandau/parallelRemake/blob/master/TROUBLESHOOTING.md) on the [GitHub page](https://github.com/wlandau/parallelRemake) for instructions.

# Example

Use the `run_example_parallelRemake()` function to run the example workflow from start to finish. The steps are as follows.

1. Use the `write_example_parallelRemake()` function to create `code.R` with example user-defined R code `remake.yml` file with the [`remake`](https://github.com/richfitz/remake) instructions to direct the workflow. The `write_example_parallelRemake()` function does steps 1 and 2.
2. Use `write_makefile()` to create the master [`Makefile`](https://www.gnu.org/software/make/) for running [`remake`](https://github.com/richfitz/remake) targets. The user will typically write `code.R` and `remake.yml` by hand and begin with this step. The `setup_example_parallelRemake()` function does steps 1 and 2.
3. Use [`Makefile`](https://www.gnu.org/software/make/) to run the workflow. The `run_example_parallelRemake()` function does steps 1 through 3. Some example options are as follows.
    - `make` just runs the workflow in 1 process.
    - `make -j 4` distributes the workflow over at most 4 parallel processes.
    - `make clean` removes the files created by [`remake`](https://github.com/richfitz/remake).
5. Optionally, use the `clean_example_parallelRemake()` function to remove all the files generated in steps 1 through 4.
    
# More on `write_makefile()`

The `write_makefile()` function has additional arguments. You can control the names of the [`Makefile`](https://www.gnu.org/software/make/) and the [`remake`](https://github.com/richfitz/remake)/[`YAML`](http://yaml.org/) file with the `makefile` and `remakefile` arguments, respectively. You can add lines to the beginning of the [`Makefile`](https://www.gnu.org/software/make/) with the `begin` argument, which could be useful for setting up the workflow for execution on a cluster, for example. You can append commands to `make clean` with the `clean` argument. In addition, the `remake_args` argument passes additional arguments to `remake::make()`. For example, `write_makefile(remake_args = list(verbose = FALSE))` is equivalent to `remake::make(..., verbose = F)` for each target. You cannot set `target_names` or `remake_file` this way because those names are reserved.

# High-performance computing

If you want to run `make -j` to distribute tasks over multiple nodes of a [Slurm](http://slurm.schedmd.com/) cluster, refer to the Makefile in [this post](http://plindenbaum.blogspot.com/2014/09/parallelizing-gnu-make-4-in-slurm.html) and write

```{r}
write_makefile(..., 
  begin = c(
    "SHELL=srun",
    ".SHELLFLAGS= <ARGS> bash -c"))
```

in an R session, where `<ARGS>` stands for additional arguments to `srun`. Then, once the [Makefile](https://www.gnu.org/software/make/) is generated, you can run the workflow with
`nohup make -j [N] &` in the command line, where `[N]` is the maximum number of simultaneous jobs to submit to the cluster.
For other task managers such as [PBS](https://en.wikipedia.org/wiki/Portable_Batch_System), this technique may not be possible. Regardless of the system, be sure that all nodes point to the same working directory so that they share the same `.remake` [storr](https://github.com/richfitz/storr) cache.

# Use with the [downsize](https://github.com/wlandau/downsize) package

The <a href="https://github.com/wlandau/downsize">downsize</a> package is compatible with <a href="https://github.com/wlandau/parallelRemake">parallelRemake</a> and <a href="https://github.com/wlandau/remakeGenerator">remakeGenerator</a> workflows, and the <a href="https://github.com/wlandau/remakeGenerator">remakeGenerator</a> README suggests one of many potential ways to use these packages together.

# Accessing the [`remake`](https://github.com/richfitz/remake) cache for debugging and testing

Intermediate [`remake`](https://github.com/richfitz/remake) objects are maintained in [`remake`](https://github.com/richfitz/remake)'s hidden [`storr`](https://github.com/richfitz/storr) cache. At any point in the workflow, you can reload them using `recall(name)`, where `name` is a character string denoting the name of a cached object, and you can see the names of all the available objects with the `recallable()` function. Enter multiple names to return a named list of multiple objects (i.e., `recall(name1, name2)`). **Important: this is only recommended for debugging and testing. Changes to the cache are not tracked and thus not reproducible.**

The functions `create_bindings()` and `make_environment()` are alternatives from [`remake`](https://github.com/richfitz/remake) itself. Just be careful with `create_bindings()` if your project has a lot of data.

# Multiple [`remake`](https://github.com/richfitz/remake)/[`YAML`](http://yaml.org/) files

[`remake`](https://github.com/richfitz/remake) has the option to split the workflow over multiple [`YAML`](http://yaml.org/) files and collate them with the "include:" field. If that's the case, just specify all the root nodes in the `remakefiles` argument to `write_makefile()`. (You could also specify every single [`YAML`](http://yaml.org/) file, but that's tedious.) If needed, `write_makefile()` will recursively combine the targets, sources, etc. in the constituent `remakefiles` and output a new collated [`YAML`](http://yaml.org/) file that the master [`Makefile`](https://www.gnu.org/software/make/) will then use.

# Acknowledgements

This package stands on the shoulders of [Rich FitzJohn](https://richfitz.github.io/)'s [`remake`](https://github.com/richfitz/remake) package, an understanding of which is a prerequisite for this one. Also thanks to [Daniel Falster](http://danielfalster.com/) for [the idea](https://github.com/richfitz/remake/issues/84) that cleaned everything up.
