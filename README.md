# rpc.io

[![NPM Version][npm-image]][npm-url]

rpc over socket.io

## usage

clientside:

```javascript
let rpc = require('rpc.io-client')(socket, 2000);  # timeout

rpc.call('users.get', {id: 1024}) # Promise
```

serverside:

```javascript
io.on('connection', (socket)=> {

    rpc = require("rpc.io")(socket);

    rpc.register('users.get', (id)=> {nickname: 'foo'});

    rpc.register('users', {
        delete: function*(id) {
            yield db.items.remove({owner: id});
            db.users.remove({_id: id});
        }
    });
});
```

### optional params

```javascript
rpc.register('projects.create', {description: ''}, (name, description)=>);
```

```javascript
socket.register('projects', {
    create_defaults: {
        description: ''
    },
    create: (name, description)=>
});
```

### handle all rpc calls

```javascript
rpc.on("call", (method, kwargs)=> throw Error `method ${method} not implemented`);
```

### handle errors

```javascript
rpc.on("error", (method, kwargs, error)=> log.error(error));
```

[npm-image]: https://img.shields.io/npm/v/rpc.io.svg?style=flat
[npm-url]: https://npmjs.org/package/rpc.io
