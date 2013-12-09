connect = require 'connect'
connect.createServer(
    connect.static(__dirname + "/webroot")
).listen 8081