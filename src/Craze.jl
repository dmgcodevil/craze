module Craze

export Event, Process, Handler, Routing, handle, start, send, handler

abstract type Event end
struct Handler{T,S} end

struct Process{T<:Event,S}
    state::S
    handler::Handler{T,S}
    chan::Channel{T}
    Process{T,S}(state::S, handler::Handler{T,S}) where {T<:Event,S} =
        new(state, handler, Channel{T}(1))
end

function send(p::Process{T}, e::T) where {T}
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

# Syntax
macro handler(ex::Expr)
    # dump(ex)
    inputType = ex.args[1].args[1].args[1]
    eventType = ex.args[1].args[2].args[2]
    stateType = ex.args[1].args[3].args[2]
    body = ex.args[2]
    quote
        function (::Handler{$__module__.$inputType,$__module__.$stateType})(e::$__module__.$eventType, s::$__module__.$stateType)
            eval($body)
        end
    end
end


module Routing
end

end # module Craze
