"""
    12_select_params.jl

# Description
Selects and saves the best-performing hyperparameters for each module and dataset from 11_grand.jl.
"""


# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using DrWatson      # collect_results!
using DataFrames

# -----------------------------------------------------------------------------
# OPTIONS
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
from_exp_name = "11_grand"
exp_name = "12_select_params"
out_df_filename = "best_params.jld2"
# out_filename = "cmt-clusters-sweep.csv"
# clusters_plot_filename = "clusters-vs-rho.png"
# column_digits = 6

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): analyze START distributed results."
)

# Point to the sweep results
sweep_dir = OAR.results_dir(
    exp_top,
    from_exp_name,
    "sweep",
)

# Output file
# output_dir(args...) = OAR.results_dir(exp_top, exp_name, args...)
# mkpath(output_dir())
# output_file = output_dir(out_filename)

# -----------------------------------------------------------------------------
# LOAD RESULTS
# -----------------------------------------------------------------------------

# Collect the results into a single dataframe
df = collect_results!(sweep_dir)
