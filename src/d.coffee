#!/usr/bin/env coffee

# https://github.com/substack/hyperquest
# stream1, emits complete response in data event
hyperquest = require "hyperquest"

# https://github.com/dominictarr/event-stream
# limited streams2
# map and other utilities
eventStream = require "event-stream"

# https://github.com/dominictarr/JSONStream
# may have leaks for large objects
JSONStream = require 'JSONStream'

# https://github.com/rvagg/node-levelup
LevelUp = require "level"

# https://github.com/dominictarr/level-sublevel
Sublevel = require "level-sublevel"
    # example sub-level use
    # sub = db.sublevel subName
    # db.put key, value, ->
    # sub.put key2, value, ->


delay = (ms, cb) ->
    setTimeout cb, ms

logger = eventStream.mapSync (doc) ->
    console.log typeof doc, doc
    doc

trimDescription = eventStream.mapSync (doc) ->
    isLong = doc.description.length > 60
    doc.description = doc.description.substr(0, 60)
    doc.description += "..."  if isLong
    doc

mapKeys = eventStream.mapSync (doc) ->
    key: doc.name
    value: doc

module.exports = queryStream = (term) ->

    uri = "http://npmsearch.com/query?fl=name,description,homepage&rows=30&sort=rating+desc&q="
    uri = uri + term

    p = hyperquest uri
    # p = p.pipe process.stdout
    p = p.pipe JSONStream.parse "response.docs.*"
    p = p.pipe trimDescription
    #p = p.pipe logger
    p = p.pipe mapKeys



if require.main is module
    dbPath = __dirname + "/db"
    dbName = "sample"
    
    # **** testing **** removes the whole db
    rimraf = require "rimraf" # CAUTION: this is rm -rf
    rimraf.sync dbPath        # CAUTION: this is rm -rf
    # *****************


    opts =
        valueEncoding:'json'
        keyEncoding: 'json'
    
    LevelUp dbPath, opts, (err, db) ->
        db = Sublevel db # allow sublevels
        subDb = db.sublevel dbName

        writeStream = subDb.createWriteStream()
        writeStream = writeStream.on 'error', (err) ->
            console.log "******error writing db stream", err

        p = queryStream "levelDb"
        p = p.pipe writeStream

        delay 5000, () ->
            readStream = subDb.createReadStream
                start: 'level'
                end: 'm'
            readStream.pipe logger
