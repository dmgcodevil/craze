module Craze

export Event, Process, Handler, Routing, handle, start, send

abstract type Event end
struct Handler{T,S} end

struct Process{T<:Event,S}
    state::S
    handler::Handler{T,S}
    chan::Channel{T}
    Process{T,S}(state::S, handler::Handler{T,S}) where {T<:Event,S} =
        new(state, handler, Channel{T}(1))
end

function send(p::Process{T,S}, e::T) where {T,S}
    put!(p.chan, e)
end

function start(p::Process{T,S}) where {T,S}
    @async while true
        e = take!(p.chan)
        handle(p, e)
    end
end

function handle(p::Process{T,S}, event::T) where {S} where {E<:T} where {T}
    p.handler(event, p.state)
end

module Routing
end

end # module Craze
