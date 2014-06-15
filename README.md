# rpc.io

rpc over socket.io, with promise

## usage

clientside:

```coffeescript
result = socket.call 'users.get', id: 1024
result.then console.log
```

serverside:

```coffeescript
socket.register 'users.get', (id)->
    nickname: 'foo'
```

### namespace

```coffeescript
socket.register 'users'

    get: (id)->
        db.fetchUser id

    update: (nickname, id)->
        db.updateUser id: id, nickname: nickname
```

classes should also work

```coffeescript
socket.register 'name.space.foo' new Foo
```

### optional params

```coffeescript
socket.register 'projects.create', {description: ''}, (name, description)->

socket.register 'projects'

    create_defaults:
        description: ''
    create: (name, description)->
```

### handle all rpc call

```coffeescript
socket.on 'rpc-call', (method, kwargs)->
```

### more on promise

socket.call returns an promise, but callback also works

```coffeescript
socket.call 'users.list', (users)->

socket.call 'users.get', id: 2048, (user)->
```

promises can be used as params

```coffeescript
project = socket.call 'projects.get', id: projectId
ownerId = project.then (project)-> project.ownerId
owner = socket.call 'users.get', id: ownerId
```

returing promise

```coffeescript
socket.register 'users.get', (id)->
    userPromise()
```

### magics(require ecmascript6)

```coffeescript
users = socket.users.list()
```

more magic

```coffeescript
{users, projects} = socket
projects.list()
```
