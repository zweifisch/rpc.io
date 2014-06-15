
getSignature = (fn)->
    params = /\(([\s\S]*?)\)/.exec fn
    if params and params[1].trim()
        params[1].split(',').map (x)-> x.trim()
    else
        []

module.exports = (socket)->

    closures = {}
    signatures = {}
    defaults = {}

    socket.register = (args...)->
        if args.length is 1
            namespace = args[0]
            return socket.register
        else if args.length is 2
            if 'function' is typeof args[1]
                [method, closure] = args
                closures[method] = closure
            else
                [namespace, methods] = args
                throw Error "unexpected params" unless 'object' is typeof methods
                for own method, closure of methods
                    closures["#{namespace}.#{method}"] = closure
                    if methods["#{method}_defaults"]
                        defaults["#{namespace}.#{method}"] = methods["#{method}_defaults"]
        else if args.length is 3
            [method, _defaults, closure] = args
            closures[method] = closure
            defaults[method] = _defaults

    socket.on 'rpc-call', (id, method, params)->
        try
            throw new Error 'params must be passed as an object' unless 'object' is typeof params  # client should ensure params passed correctly
            throw new Error "method not registered: #{method}" unless method of closures
            signatures[method] = getSignature closures[method] unless method in signatures
            preparedParams = []
            for own name, value of params
                throw new Error "unexpected param: #{name}" unless name in signatures[method]
            for name in signatures[method]
                if name not of params
                    if defaults[method] and name of defaults[method]
                        preparedParams.push defaults[method][name]
                    else
                        throw new Error "param missing: #{name}"
                else
                    preparedParams.push params[name]
            result = closures[method] preparedParams...
            if 'function' is typeof result?.then
                result.then (value)-> socket.emit 'rpc-result', id, value
                result.catch (err)-> socket.emit 'rpc-result', id, null, err
            else
                socket.emit 'rpc-result', id, result
        catch e
            socket.emit 'rpc-result', id, null, e.message

    socket
