"""
    ebnf.jl

# Description
Demo experiment with an extended Backus-Naur form grammar.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Create a discretized symbolic version of the IRIS dataset
N = [
    "SL", "SW", "PL", "PW",
]

bins = 10

# bnf = OAR.DescretizedCFG(N)
bnf = OAR.DescretizedCFG(OAR.quick_statement(N), bins=bins)

statement = OAR.random_statement(bnf)

@info statement
