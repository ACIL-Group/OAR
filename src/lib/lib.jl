"""
    lib.jl

# Description
Aggregates all common types and functions that are used throughout the `OAR` project.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

# Version of the package as a constant
include("version.jl")

# Common docstrings and their templates
include("docstrings.jl")

# DrWatson extensions
include("drwatson.jl")

# Grammars and the Backus-Naur form
# include("grammar.jl")
include("grammar/lib.jl")

# GramART Julia implementation
include("GramART.jl")

# Lerche parsers
include("parsers/lib.jl")

# Data utilities
include("data_utils.jl")

# File and options utilities
include("file.jl")
