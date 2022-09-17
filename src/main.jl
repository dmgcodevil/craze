#=
main:
- Julia version: 
- Author: dmgco
- Date: 2022-09-13
=#
include("Craze.jl")

using .Craze

struct Foo <: Event end
struct Bar <: Event end


mutable struct State
    count::Int
end

# API
Input = Union{Foo,Bar}

# Handlers
function (::Handler{Input,State})(e::Foo, s::State)
    println("handle Foo")
end

function (::Handler{Input,State})(e::Bar, s::State)
    println("handle Bar")
end

p = Process{Input,State}(State(0), Handler{Input,State}())
handle(p, Foo())
handle(p, Bar())
