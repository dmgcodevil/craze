module Craze

export Event, Process, Handler, Routing, handle, start, stop, send, handler, ControlEvent, Start, Stop

abstract type Event end

# Predifined events
abstract type ControlEvent <: Event end
struct Start <: ControlEvent end
struct Stop <: ControlEvent end

struct Handler{T,S} end


struct Process{T<:Event,S}
    state::S
    handler::Handler{T,S}
    chan::Channel{Union{T,ControlEvent}}
    Process{T,S}(state::S, handler::Handler{T,S}) where {T<:Event,S} =
        new(state, handler, Channel{Union{T,ControlEvent}}(1))
end

function send(p::Process{T}, e::T) where {T}
    put!(p.chan, e)
end

stop(p::Process) = put!(p.chan, Stop())


function start(p::Process{T,S}) where {T,S}
    @async while true
        e = take!(p.chan)
        if isa(e, Stop)
            if Stop <: T
                handle(p, e)
            end
            break
        elseif isa(e, Start) && Start <: T
            handle(p, e)
        else
            handle(p, e)
        end
    end
end

function handle(p::Process{T,S}, event::T) where {S} where {E<:T} where {T}
    p.handler(event, p.state)
end

# Syntax
macro handler(ex::Expr)
    inputType = ex.args[1].args[1].args[1]
    eventType = ex.args[1].args[2].args[2]
    stateType = ex.args[1].args[3].args[2]
    eventVar = Symbol(ex.args[1].args[2].args[1])
    stateVar = Symbol(ex.args[1].args[3].args[1])
    body = ex.args[2]
    quote
        function (::Handler{$__module__.$inputType,$__module__.$stateType})($eventVar::$__module__.$eventType, $stateVar::$__module__.$stateType)
            $body
        end
    end
end


module Routing
end

end # module Craze
