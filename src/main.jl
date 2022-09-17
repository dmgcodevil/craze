#=
main:
- Julia version: 
- Author: dmgco
- Date: 2022-09-13
=#
include("Craze.jl")

using .Craze
import .Craze: @handler

struct Foo <: Event end
struct Bar <: Event end


mutable struct State
    count::Int
end

# API
Input = Union{Foo,Bar}

# Handlers
@handler {Input}(e::Bar, s::State) = println("handle: ", e)
@handler {Input}(e::Foo, s::State) =
    begin
        println("handle: ", e, " start")
        println("handle: ", e, " end")
    end

p = Process{Input,State}(State(0), Handler{Input,State}())
handle(p, Foo())
handle(p, Bar())
send(p, Foo())
start(p)
sleep(5000)
