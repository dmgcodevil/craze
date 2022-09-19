#=
ProcessTest:
- Julia version: 1.8.1
- Author: dmgco
- Date: 2022-09-18
=#

include("../src/Craze.jl")

using Test
using .Craze
import .Craze: @handler

struct Foo <: Event end
struct Bar <: Event end
Input = Union{Foo,Bar}

mutable struct State
    count::Int
end

@testset "handle-control-events" begin
    p = Process{Input,State}(State(0))
    @handler Process{Input}::(event::Start, state::State) = state.count = state.count + 1
    @handler Process{Input}::(event::Stop, state::State) = state.count = state.count + 2
    start(p)
    stop(p)
    sleep(3)

    @test p.state.count == 3
end

@testset "handle-1" begin
    p = Process{Input,State}(State(0))
    @handler Process{Input}::(event::Bar, state::State) = state.count = state.count + 1
    @handler Process{Input}::(event::Foo, state::State) = state.count = state.count + 2
    handle(p, Bar())
    handle(p, Foo())
    @test p.state.count == 3
end