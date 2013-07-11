
http = require("http")
ws = require("ws")
websocket = require("websocket-stream")
through = require("through")
browserify = require("browserify")
path = require("path")

entry = path.resolve(process.argv[3])

module.exports = ->
    actual = through()
    expected = through().pause()
    expected.queue "hello\n"
    expected.queue null

    httpServer = http.createServer((req, res) ->
        if req.url is "/bundle.js"
            res.setHeader "content-type", "text/javascript"
            browserify(entry).bundle
                debug: true
            , (err, src) ->
                console.error err    if err
                res.end src

        else
            res.setHeader "content-type", "text/html"
            res.end "<script src=\"/bundle.js\"></script>"
    )
    wsServer = new ws.Server(
        noServer: true
        clientTracking: false
    )
    httpServer.on "upgrade", (req, socket, head) ->
        httpServer.on "_close", ->
            socket.destroy()

        wsServer.handleUpgrade req, socket, head, (conn) ->
            stream = websocket(conn)
            stream.pipe actual


    httpServer.listen 8000
    console.log "################################################"
    console.log "#                                                                                            #"
    console.log "# Open http://localhost:8000 to run your code! #"
    console.log "#                                                                                            #"
    console.log "################################################"
    console.log()
    args: []
    a: actual
    b: expected
    close: ->
        httpServer.close()
        httpServer.emit "_close"
        wsServer.close()
        setTimeout process.exit, 50
