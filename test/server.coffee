express = require 'express'
app = express()
http = require('http').Server app
io = require('socket.io') http
rpc = require '../index'
ccjs = require 'ccjs'
Promise = require 'promise'

app.use express.static __dirname + '/../'

app.use ccjs.middleware
    root:"#{__dirname}/"
    coffee:on

app.get '/', (req, res)->
    res.sendfile 'index.html'

io.on 'connection', (socket)->
    socket = rpc socket

    socket.register 'add', (n1, n2)->
        n1 + n2

    socket.register 'sleep', (time)->
        new Promise (resolve, reject)->
            setTimeout (-> resolve 'wakeup'), time

    socket.register 'error', (msg)->
        throw new Error msg

    socket.emit 'welcome', 'msg'

http.listen 3000, ->
    console.log 'listening on *:3000'
