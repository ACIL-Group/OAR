"""
    1_iris.jl

# Description
This script shows how to use a START to cluster on the Iris dataset.

# Attribution

## Citations
- Fisher, R. A.. (1988). Iris. UCI Machine Learning Repository. https://doi.org/10.24432/C56C76.

## BibTeX
@misc{misc_iris_53,
    author       = {Fisher,R. A.},
    title        = {{Iris}},
    year         = {1988},
    howpublished = {UCI Machine Learning Repository},
    note         = {{DOI}: https://doi.org/10.24432/C56C76}
}
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using Random
Random.seed!(1234)
using ProgressMeter

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
exp_name = "1_iris.jl"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): START for clustering the real-valued UCI Iris dataset."
)

# -----------------------------------------------------------------------------
# IRIS DATASET
# -----------------------------------------------------------------------------

# All-in-one function
data, grammmar = OAR.symbolic_iris()

# Initialize the START module with options
gramart = OAR.START(
    grammmar,
    rho = 0.15,
    rho_lb = 0.1,
    rho_ub = 0.25,
)

# Process the statements
@showprogress for ix in eachindex(data.train_x)
    statement = data.train_x[ix]
    label = data.train_y[ix]
    # OAR.train!(gramart, statement, y=label)
    OAR.train_dv!(gramart, statement, y=label)
end

# See the statistics of the first protonode
# @info gramart.protonodes[1].stats

# Classify
clusters = zeros(Int, length(data.test_y))
@showprogress for ix in eachindex(data.test_x)
    # clusters[ix] = OAR.classify(gramart, data.test_x[ix], get_bmu=true)
    clusters[ix] = OAR.classify_dv(gramart, data.test_x[ix], get_bmu=true)
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(data.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"
