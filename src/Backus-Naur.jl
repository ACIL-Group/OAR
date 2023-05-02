"""
    Backus-Naur.jl

# Description
This file implements the parsing and generation of statements with the Backus-Naur form.
"""

# -----------------------------------------------------------------------------
# ABSTRACT TYPES
# -----------------------------------------------------------------------------

"""
Abstract type for formal grammars.
"""
abstract type Grammar end

"""
A grammar symbol is a String.
"""
const GSymbol = String

"""
A set of GSymbols.
"""
const GSymbolSet = Set{GSymbol}

"""
A production rule is a set of vectors of symbols.
"""
const ProductionRule = Set{Vector{GSymbol}}
# const ProductionRule = Dict{GSymbol, GSymbolSet}

"""
A production rule set is simply a set of production rules.
"""
const ProductionRuleSet = Dict{GSymbol, ProductionRule}

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
Backus-Naur form grammar.

Consists of a set of terminal symbols, non-terminal symbols, and production rules.
"""
struct BNF <: Grammar
    """
    Non-terminal symbols of the grammar.
    """
    N::GSymbolSet

    """
    Terminal symbols of the grammar.
    """
    T::GSymbolSet

    """
    The set of production rules of the grammar.
    """
    P::ProductionRuleSet
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

"""
Constructor for a Backus-Naur Form grammer with an initial set of non-terminal symbols.

# Arguments
- `N::GSymbolSet`: an initial set of non-terminal grammar symbols.
"""
function BNF(N::GSymbolSet)
    return BNF(
        N,
        GSymbolSet(),
        ProductionRuleSet(),
    )
end

"""
Default constructor for the Backus-Naur Form.
"""
function BNF()
    return BNF(GSymbolSet())
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

# function incremented_gsymbol(bin::Integer)

# end

"""
Creates a grammer for discretizing a set of symbols into a number of bins.

# Arguments
- `N::GSymbolSet`: the set of non-terminal grammar symbols to use for binning.
- `bins::Integer=10`: optional, the granularity/number of bins.
"""
function DescretizedBNF(N::GSymbolSet ; bins::Integer=10)
# function DescretizedBNF(data::RealMatrix, N::GSymbolSet ; bins::Integer=10)
    # Create an initial BNF
    # bnf = BNF(N)
    # Initialize the terminal symbol set
    T = GSymbolSet()
    # Initialize the production rule set
    P = ProductionRuleSet()
    # Iterate over each non-terminal symbol
    for symb in N
        # Iterate over the number of discretized bins that we want
        for ix = 1:bins
            # Create a binned symbol
            new_gsymbol = symb + string(ix)
            # Push a binned symbol to the terminals
            push!(T, new_gsymbol)
            push!(P[symb], new_gsymbol)
        end
    end

    # Return a constructed BNF struct
    return BNF(
        N,
        T,
        P,
    )
end
