#!/usr/bin/env coffee

http = require "http"
fs = require "fs"
path = require "path"

JSONStream = require "JSONStream"

trumpet = require "trumpet"
render = require "./render/article"

server = http.createServer (req, res) ->
    res.setHeader "content-type", "text/html"

    # tr is a stream that takes html and returns transformed html
    tr = trumpet()
    
    # stream to content, whenever that element passes through tr
    toContent = tr.select("#content").createWriteStream()


    # source stream for #content
    topPath = path.join __dirname, ".."

    p = fs.createReadStream path.join topPath, "/data/data.json"
    p = p.pipe JSONStream.parse [true] # same as "*" but safe for key like ".name"
    
    # pipe source to render
    p = p.pipe render()
    
    # pipe rendered source to #content element
    p = p.pipe toContent
    
    # stream reading the target html
    p = fs.createReadStream path.join topPath, "/index.html"
    
    # pipe to transform, pipe to response
    p = p.pipe tr
    p = p.pipe res

server.listen 5000, () ->
    console.log "running on localhost:5000"



