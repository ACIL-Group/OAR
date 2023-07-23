"""
    runtests.jl

The entry point to unit tests for the `OAR` project.
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

using SafeTestsets

# -----------------------------------------------------------------------------
# SAFETESTSETS
# -----------------------------------------------------------------------------

@safetestset "All Test Sets" begin
    include("test_sets.jl")
end
