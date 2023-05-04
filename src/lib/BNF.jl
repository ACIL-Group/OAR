"""
    BNF.jl

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
Parametric abstract symol type for [`Grammars`](@ref OAR.Grammar).
"""
abstract type AbstractSymbol{T} end

"""
Value-as-type parametric type for terminal symbols.
"""
struct Terminal{T} <: AbstractSymbol{T}
    # """
    # The grammar symbol of type T.
    # """
    # symb::T
end

"""
Value-as-type parametric type for nonterminal symbols.
"""
struct NonTerminal{T} <: AbstractSymbol{T}
    # """
    # The grammar symbol of type T.
    # """
    # symb::T
end

"""
Definition for a set of symbols, terminal or nonterminal.
"""
struct SymbolSet{T <: AbstractSymbol}
    data::Set{T}
end

"""
Convenience function that makes a SymbolSet from a vector of grammar symbols.
"""
function SymbolSet(symbs::Vector{T}) where T <: AbstractSymbol
    return SymbolSet(
        Set(symbs)
    )
end

# const ProductionRule = SymbolSet

# struct ProductionRuleSet{T <: AbstractSymbol}

# end

# function getindex(h::)
# function getindex(A::SymbolSet, i1::Integer)
#     return
# end

# struct ProductionRule{}

# -----------------------------------------------------------------------------
# TYPE ALIASES
# -----------------------------------------------------------------------------

"""
A grammar symbol is a String.
"""
const GSymbol = String


# """
# Definition of a Terminal symbol as a [`GSymbol`](@ref OAR.GSymbol).
# """
# const Terminal = GSymbol

# """
# Definition of a NonTermial symbol as a [`GSymbol`](@ref OAR.GSymbol).

# Though both [`Terminal`](@ref OAR.Terminal) and [`NonTerminal`](@ref OAR.NonTerminal) symbols are defined with the same data structure, they are disambiguated in how they are used in [`Grammars`](@ref OAR.Grammar).
# """
# const NonTerminal = GSymbol

"""
A set of [`GSymbols`](@ref GSymbol).
"""
const GSymbolSet = Set{GSymbol}

"""
A production rule is a set of [`GSymbols`](@ref OAR.GSymbol).
"""
const ProductionRule = Set{GSymbol}

"""
A production rule set is simply a set of [`ProductionRules`](@ref OAR.ProductionRule).
"""
const ProductionRuleSet = Dict{GSymbol, ProductionRule}

"""
A statement is an ordered vector of [`GSymbols`](@ref OAR.GSymbol).
"""
const Statement = Vector{GSymbol}

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
Backus-Naur form of [`Grammar`](@ref OAR.Grammar).

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
    Definition of a statement in this grammar.
    """
    S::Statement

    """
    The set of production rules of the grammar.
    """
    P::ProductionRuleSet
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

"""
Constructor for a Backus-Naur Form grammer with an initial statement of non-terminal symbols.

# Arguments
- `N::STatement`: an initial set of non-terminal grammar symbols.
"""
function BNF(S::Statement)
    return BNF(
        Set(S),
        S,
        GSymbolSet(),
        ProductionRuleSet(),
    )
end

"""
Default constructor for the Backus-Naur Form.
"""
function BNF()
    return BNF(Statement())
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Returns a new GSymbol by adding a suffix.
"""
function join_gsymbol(symb::GSymbol, num::Integer)
    return symb * string(num)
end

"""
Creates a grammer for discretizing a set of symbols into a number of bins.

# Arguments
- `N::Statement`: the set of non-terminal grammar symbols to use for binning.
- `bins::Integer=10`: optional, the granularity/number of bins.
"""
function DescretizedBNF(S::Statement ; bins::Integer=10)
    # Initialize the terminal symbol set
    T = GSymbolSet()
    # Initialize the production rule set
    P = ProductionRuleSet()
    # Iterate over each non-terminal symbol
    for symb in S
        # Create a new production rule with the non-terminal as the start
        P[symb] = ProductionRule()
        # Iterate over the number of discretized bins that we want
        for ix = 1:bins
            # Create a binned symbol
            new_gsymbol = join_gsymbol(symb, ix)
            # Push a binned symbol to the terminals
            push!(T, new_gsymbol)
            # alt = Alternative()
            # push!(alt, new_gsymbol)
            push!(P[symb], new_gsymbol)
        end
    end

    # Return a constructed BNF struct
    return BNF(
        Set(S),     # N
        T,          # T
        S,          # S
        P,          # P
    )
end

"""
Parses and checks that a statement is permissible under a grammer.
"""
function parse_grammar(grammar::Grammar, statement::Statement)
    return
end

"""
Produces a random terminal from the non-terminal using the corresponding production rule.
"""
function random_produce(grammar::Grammar, symb::GSymbol)
    return rand(grammar.P[symb])
end

"""
Checks if a symbol is terminal in the grammar.
"""
function is_terminal(grammar::Grammar, symb::GSymbol)
    return symb in grammar.T
end

"""
Checks if a symbol is non-terminal in the grammar.
"""
function is_nonterminal(grammar::Grammar, symb::GSymbol)
    return symb in grammar.N
end

"""
Generates a random statement from a grammar.
"""
function random_statement(grammar::Grammar)
    # rand_N = rand(grammar.N)
    statement = Statement()
    for el in grammar.S
        rand_symb = random_produce(grammar, el)
        if is_terminal(grammar, rand_symb)
            push!(statement, random_produce(grammar, el))
        end
    end

    return statement
end
