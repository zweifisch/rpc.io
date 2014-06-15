
getSignature = (fn)->
    params = /\(([\s\S]*?)\)/.exec fn
    if params
        params[1].split(',').map (x)-> x.trim()
    else
        []

module.exports = (socket)->

    namespace = null
    closures = {}
    signatures = {}
    defaults = {}

    socket.register = (args...)->
        if namespace
            throw Error "unexpected args #{args}" unless args.length is 1
            throw Error unless 'object' is typeof args[0]
            for own method, closure of args[0]
                closures["#{namespace}.#{method}"] = closure
                if args[0]["#{method}_defaults"]
                    defaults["#{namespace}.#{method}"] = args[0]["#{method}_defaults"]
            namespace = null
        else
            if args.length is 1
                namespace = args[0]
                return socket.register
            else if args.length is 2
                [method, closure] = args
                closures[method] = closure
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
                        preparedParams.push defaults[method]
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
