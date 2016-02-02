co = require "co"

getSignature = (fn)->
    params = /\(([\s\S]*?)\)/.exec fn
    if params and params[1].trim()
        params[1].split(',').map (x)-> x.trim()
    else
        []

merge = (base, more)->
    ret = {}
    if "object" is typeof base
        for own key,val of base
            ret[key] = val
    if "object" is typeof more
        for own key,val of more
            ret[key] = val
    ret

module.exports = (socket)->

    handlers = {}
    signatures = {}
    defaults = {}
    defaultHandler = null

    register = (name, handler, defaultParams)->
        if handler.constructor.name is 'GeneratorFunction'
            signatures[name] = getSignature handler
            handler = co.wrap handler
        handlers[name] = handler
        defaults[name] = defaultParams if defaultParams

    socket.register = (args...)->
        if args.length is 1
            namespace = args[0]
            return socket.register
        else if args.length is 2
            if 'function' is typeof args[1]
                [method, handler] = args
                register method, handler
            else
                [namespace, methods] = args
                throw Error "unexpected params" unless 'object' is typeof methods
                for own method, handler of methods
                    if 'function' is typeof handler
                        register "#{namespace}.#{method}", handler, methods["#{method}_defaults"]
        else if args.length is 3
            [method, defaultParams, handler] = args
            register method, handler, defaultParams

    rpchandler = (method, params, id)->
        if method not of handlers
            if defaultHandler
                return defaultHandler method, params, id
            throw new Error "method not registered: #{method}" unless method of handlers
        throw new Error 'params must be passed as an object' unless 'object' is typeof params  # client should ensure params passed correctly
        signatures[method] = getSignature handlers[method] unless method of signatures
        preparedParams = []
        for own name, value of params
            throw new Error "unexpected param: #{name}" unless name in signatures[method]
        for name in signatures[method]
            if name not of params
                if defaults[method] and name of defaults[method]
                    preparedParams.push defaults[method][name]
                else if name is "kwargs"
                    preparedParams.push merge defaults[method], params
                else
                    throw new Error "param missing: #{name}"
            else
                preparedParams.push params[name]
        handlers[method] preparedParams...

    socket.onrpc = (handler)->
        defaultHandler = handler

    socket.on 'rpc-call', (id, method, params) ->
        try
            result = rpchandler method, params, id
            if 'function' is typeof result?.then
                result.then (value)-> socket.emit 'rpc-result', id, value
                result.catch (err)-> socket.emit 'rpc-result', id, null, err?.message or err
            else
                socket.emit 'rpc-result', id, result
        catch e
            socket.emit 'rpc-result', id, null, e.message

    socket
