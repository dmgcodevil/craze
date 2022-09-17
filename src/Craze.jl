module Craze

export Event, Process, Handler, Routing, handle

abstract type Event end
struct Handler{T,S} end

struct Process{T<:Event,S}
    state::S
    handler::Handler{T,S}
end

function handle(p::Process{T,S}, event::T) where {S} where {E<:T} where {T}
    p.handler(event, p.state)
end

module Routing
end

end # module Craze
