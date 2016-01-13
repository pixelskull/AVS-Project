var app = require('express')()
var http = require('http').Server(app)
var io = require('socket.io')(http)


app.get('/', function(req, res) {
  res.send('<body><script src="/socket.io/socket.io.js"></script><script> var socket = io(); </script></body>')
});


io.on('connection', function(sockets){
  console.log('a user connected')
});

http.listen(3000, function(){
  console.log('listening on *:3000')
});
