// var app = require('express')();

var WebsocketServer = require('websocket').server;
var http = require('http') //.Server(app);
var conf = require('./config.json')

var server = http.createServer(function(req, res) {
  console.log("NODE.JS::::" + (new Date()) + ' recieved request for ' + req.url);
  res.writeHead(404);
  res.end();
});

var connections = [];




server.listen(conf.port, function() {
  console.log("NODE.JS::: " + (new Date()) + ' Server is listening on port ' + conf.port);
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
    req.reject();
    console.log("NODE.JS::: connection rejected");
  }

  var connection = req.accept('distributed_hashcracker_protocol', req.origin);
  console.log("NODE.JS::: " + (new Date()) + 'connection accepted.');

  connections.push(connection)

  connection.on('close', function() {
        console.log("NODE.JS::: " + connection.remoteAddress + " disconnected")
        var index = connections.indexOf(connection);
        if (index !== -1) {
            connections.splice(index, 1)
        }
  })

  connection.on('message', function(message) {
        if (message.type === 'utf8') {
            console.log("NODE.JS::: Received Message: " + message.utf8Data);
            //connection.sendUTF(message.utf8Data);
            connections.forEach(function(destination) {
                destination.sendUTF(message.utf8Data);
            });
        }
        else if (message.type === 'binary') {
            console.log("NODE.JS::: Received Binary Message of ' + message.binaryData.length + ' bytes");
            //connection.sendBytes(message.binaryData);
            connections.forEach(function(destination) {
                destination.sendUTF(message.utf8Data);
            });
        }
  });
});

function exitHandler(options, err) {
    server.close();
    if (options.cleanup) console.log("NODE.JS::: clean");
    if (err) console.log("NODE.JS::: " + err.stack);
    if (options.exit) process.exit();
    process.exit()
}

//do something when app is closing
process.on('exit', exitHandler.bind(null,{cleanup:true}));

//catches ctrl+c event
process.on('SIGINT', exitHandler.bind(null, {exit:true}));

//catches SIGTERM event
process.on('SIGTERM', exitHandler.bind(null, {exit:true}));

//catches uncaught exceptions
process.on('uncaughtException', exitHandler.bind(null, {exit:true}));
