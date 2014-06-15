// Generated by CoffeeScript 1.7.1
(function() {
  var Promise, app, ccjs, express, http, io, rpc;

  express = require('express');

  app = express();

  http = require('http').Server(app);

  io = require('socket.io')(http);

  rpc = require('../index');

  ccjs = require('ccjs');

  Promise = require('promise');

  app.use(express["static"](__dirname + '/../'));

  app.use(ccjs.middleware({
    root: "" + __dirname + "/",
    coffee: true
  }));

  app.get('/', function(req, res) {
    return res.sendfile('index.html');
  });

  io.on('connection', function(socket) {
    socket = rpc(socket);
    socket.register('add', function(n1, n2) {
      return n1 + n2;
    });
    socket.register('sleep', function(time) {
      return new Promise(function(resolve, reject) {
        return setTimeout((function() {
          return resolve('wakeup');
        }), time);
      });
    });
    socket.register('error', function(msg) {
      throw new Error(msg);
    });
    return socket.emit('welcome', 'msg');
  });

  http.listen(3000, function() {
    return console.log('listening on *:3000');
  });

}).call(this);
