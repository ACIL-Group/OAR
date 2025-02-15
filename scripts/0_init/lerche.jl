"""
    lerche.jl

# Description
This file demonstrates the usage of the Lerch.jl package for parsing statements.
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

using Revise
using Lerche

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

json_grammar = raw"""
    ?start: value

    ?value: object
            | array
            | string
            | SIGNED_NUMBER      -> number
            | "true"             -> t
            | "false"            -> f
            | "null"             -> null

    array  : "[" [value ("," value)*] "]"
    object : "{" [pair ("," pair)*] "}"
    pair   : string ":" value

    string : ESCAPED_STRING

    %import common.ESCAPED_STRING
    %import common.SIGNED_NUMBER
    %import common.WS

    %ignore WS
""";

struct TreeToJson <: Transformer end

@inline_rule string(t::TreeToJson, s) = replace(s[2:end-1],"\\\""=>"\"")

@rule  array(t::TreeToJson,a) = Array(a)
@rule  pair(t::TreeToJson,p) = Tuple(p)
@rule  object(t::TreeToJson,o) = Dict(o)
@inline_rule number(t::TreeToJson,n) = Base.parse(Float64,n)

@rule  null(t::TreeToJson,_) = nothing
@rule  t(t::TreeToJson,_) = true
@rule  f(t::TreeToJson,_) = false

json_parser = Lark(json_grammar, parser="lalr", lexer="standard", transformer=TreeToJson());

text = raw"{\"key\": [\"item0\", \"item1\", 3.14]}"

j = Lerche.parse(json_parser,text)
