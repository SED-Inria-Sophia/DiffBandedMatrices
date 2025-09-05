# Quick Guide

```bash
# setup a conda environment called "julia"
conda create --name julia
conda activate julia
conda install juliaup

# Run the tests using the local files
julia tests.jl
julia tests2.jl

# Run the test using the module stored on github
cd example
julia test_module.jl
```