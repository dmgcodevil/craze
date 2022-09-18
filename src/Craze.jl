module Craze

export Event, Process, Handler, Routing, handle, start, stop, send, handler, ControlEvent, Start, Stop

abstract type Event end

# Predifined events
abstract type ControlEvent <: Event end
struct Start <: ControlEvent end
struct Stop <: ControlEvent end

mutable struct Process{T<:Event,S}
    state::S
    chan::Channel{Union{T,ControlEvent}}
    @atomic started::Bool
    @atomic stopped::Bool
    Process{T,S}(state::S) where {T<:Event,S} =
        new(state,
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
        if isa(event, Stop) && hasmethod(p, Tuple{Stop,S})
            (_, stopped) = @atomicreplace p.stopped false => true
            if stopped
                p(event, p.state)
            else
                error("process is already stoped")
            end
            break
        elseif isa(event, Start) && hasmethod(p, Tuple{Start,S})
            p(event, p.state)
        else
            p(event, p.state)
        end
    @info "event loop has been terminated"
    end
end

function handle(p::Process{T,S}, event::T) where {T,S}
    p(event, p.state)
end

# Syntax
macro handler(ex::Expr)
    # dump(ex)
    def = ex.args[1]
    body = ex.args[2]
    inputType = def.args[1].args[2]
    eventType = def.args[2].args[1].args[2]
    stateType = def.args[2].args[2].args[2]
    eventVar = Symbol(def.args[2].args[1].args[1])
    stateVar = Symbol(def.args[2].args[2].args[1])

    quote
        function (::Process{$__module__.$inputType,$__module__.$stateType})($eventVar::$__module__.$eventType, $stateVar::$__module__.$stateType)
            $body
        end
    end
end


module Routing
end

end # module Craze
