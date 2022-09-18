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
@handler {Input}(event::Bar, state::State) = println("handle: ", event, ", state: ", state)
@handler {Input}(e::Foo, s::State) =
    begin
        println("handle: ", e, " start")
        println("handle: ", e, " end")
    end

@handler {Input}(event::Start, state::State) = println("process has been started")
@handler {Input}(event::Stop, state::State) = println("process has been stopped")

p = Process{Input,State}(State(0))

handle(p, Foo())
handle(p, Bar())
start(p)
send(p, Foo())
stop(p)
sleep(1000)
