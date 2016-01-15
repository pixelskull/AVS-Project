// var app = require('express')();

var WebsocketServer = require('websocket').server;
var http = require('http') //.Server(app);
var conf = require('./config.json')

var server = http.createServer(function(req, res) {
  console.log((new Date()) + ' recieved request for ' + req.url);
  res.writeHead(404);
  res.end();
});

server.listen(conf.port, function() {
  console.log((new Date()) + ' Server is listening on port ' + conf.port);
});

wsServer = new WebsocketServer({
  httpServer: server,
  autoAcceptConnections: false
});

function originIsAllowed(origin) {
  return true;
}

wsServer.on('request', function(req) {
  if (!originIsAllowed(req.origin)) {
    console.log('foooooo');
    req.reject();
  }

  var connection = req.accept('echo-protocol', req.origin);
  console.log((new Date()) + 'connection accepted.');
  connection.on('message', function(message) {
    if (message.type === 'utf8') {
            console.log('Received Message: ' + message.utf8Data);
            connection.sendUTF(message.utf8Data);
        }
        else if (message.type === 'binary') {
            console.log('Received Binary Message of ' + message.binaryData.length + ' bytes');
            connection.sendBytes(message.binaryData);
        }
  });
});
