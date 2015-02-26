# rpc.io

[![NPM Version][npm-image]][npm-url]

rpc over socket.io, with promise

## usage

clientside:

```coffeescript
socket = require('rpc.io-client')(2000)  # timeout

socket.call 'users.get', id: 1024
.then (result)->
```

serverside:

```coffeescript
io.on 'connection', (socket)->
    socket = rpc socket

    socket.register 'users.get', (id)->
        nickname: 'foo'
```

### namespace

```coffeescript
socket.register 'users',

    get: (id)->
        db.fetchUser id

    update: (nickname, id)->
        db.updateUser id: id, nickname: nickname
```

classes should also work

```coffeescript
socket.register 'name.space.foo', new Foo
```

### optional params

```coffeescript
socket.register 'projects.create', {description: ''}, (name, description)->
```

```coffeescript
socket.register 'projects'

    create_defaults:
        description: ''
    create: (name, description)->
```

### more on promise

`socket.call` returns a promise, but callback also works

```coffeescript
socket.call 'users.list', (users)->

socket.call 'users.get', id: 2048, (user)->
```

promises can be used as params(TBD)

```coffeescript
project = socket.call 'projects.get', id: projectId
ownerId = project.then (project)-> project.ownerId
owner = socket.call 'users.get', id: ownerId
```

server-side handlers should return promises for async operation

```coffeescript
socket.register 'users.get', (id)->
    new Promise (resolve, reject)->
```

### handle all rpc calls

```coffeescript
socket.onrpc (method, kwargs)->
    throw Error "method #{method} not implemented"

socket.onrpc (method, kwargs)->
    "result"

socket.onrpc (method, kwargs)->
    new Promise (reslove, reject)->
```

### magics(require ecmascript6 TBD)

```coffeescript
users = socket.users.list()
```

more magic

```coffeescript
{users, projects} = socket
projects.list()
```

[npm-image]: https://img.shields.io/npm/v/rpc.io.svg?style=flat
[npm-url]: https://npmjs.org/package/rpc.io
