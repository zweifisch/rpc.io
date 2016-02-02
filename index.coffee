evocatio = require 'evocatio'
serializeError = require 'serialize-error'

module.exports = (socket, opts)->

    {event, onResult, onError, onCall, onMissing} = opts or {}

    fns = evocatio onMissing

    onResult or= ->
    onError or= (error)-> throw error
    onCall or= ->

    event or= "rpc-call"

    socket.on event, (id, method, params) ->
        onCall method, params
        try
            result = fns.dispatch method, params
            if 'function' is typeof result?.then
                result.then (value)->
                    onResult value, method, params
                    socket.emit 'rpc-result', id, value
                result.catch (err)->
                    onError err, method, params
                    socket.emit 'rpc-result', id, null, serializeError err
            else
                onResult result, method, params
                socket.emit 'rpc-result', id, result
        catch err
            onError err, method, params
            socket.emit 'rpc-result', id, null, serializeError err

    register: fns.register
