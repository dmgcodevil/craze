module Craze

export Event, Process, Handler, Routing, handle, start, stop, send, handler, ControlEvent, Start, Stop

abstract type Event end

# Predifined events
abstract type ControlEvent <: Event end
struct Start <: ControlEvent end
struct Stop <: ControlEvent end

struct Handler{T,S} end

mutable struct Process{T<:Event,S}
    state::S
    handler::Handler{Union{T,ControlEvent},S}
    chan::Channel{Union{T,ControlEvent}}
    @atomic started::Bool
    @atomic stopped::Bool
    Process{T,S}(state::S) where {T<:Event,S} =
        new(state,
            Handler{Union{T,ControlEvent},S}(),
            Channel{Union{T,ControlEvent}}(1),
            false,
            false)
end

function send(p::Process{T}, e::T) where {T}
    put!(p.chan, e)
end


stop(p::Process) = put!(p.chan, Stop())

function start(p::Process{T,S}) where {T,S}
    (_, started) = @atomicreplace p.started false => true
    if started
        put!(p.chan, Start())
    else
        error("process is already started")
    end
    @async while true
        event = take!(p.chan)
        if isa(event, Stop) && hasmethod(p.handler, Tuple{Stop,S})
            (_, stopped) = @atomicreplace p.stopped false => true
            if stopped
                p.handler(event, p.state)
            else
                error("process is already stoped")
            end
            break
        elseif isa(event, Start) && hasmethod(p.handler, Tuple{Start,S})
            p.handler(event, p.state)
        else
            p.handler(event, p.state)
        end
    end
end

function handle(p::Process{T,S}, event::T) where {T,S}
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
        function (::Handler{Union{$__module__.$inputType,ControlEvent},$__module__.$stateType})($eventVar::$__module__.$eventType, $stateVar::$__module__.$stateType)
            $body
        end
    end
end


module Routing
end

end # module Craze
