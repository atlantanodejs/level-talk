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

# https://github.com/dominictarr/level-live-stream
LiveStream =  require 'level-live-stream'
# see also https://github.com/dominictarr/pull-level

Store = require 'level-store'


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
        #db = Sublevel db # allow sublevels
        #subDb = db.sublevel dbName

        store = Store db

        writeStream = store.createWriteStream dbName

        console.log "reading and logging to console ***********"
        p = store.createReadStream dbName, live:true
        p = p.pipe logger

        delay 5000, () ->
            console.log "now writing ***********"
            p = queryStream "level"
            p = p.pipe writeStream

            delay 5000, () ->

###
    
 
    opts =
        valueEncoding:'json'
        keyEncoding: 'json'
    
    LevelUp dbPath, opts, (err, db) ->
        db = Sublevel db # allow sublevels
        subDb = db.sublevel dbName

        # LiveStream.install subDb

        writeStream = subDb.createWriteStream()
        writeStream = writeStream.on 'error', (err) ->
            console.log "******error writing db stream", err

        p = queryStream "levelDb"
        p = p.pipe writeStream


        delay 5000, () ->

            #liveReadStream = subDb.liveStream
            liveReadStream = LiveStream subDb,
                tail: true      # get live updates
                min: "level"   # lowest key in range
                max: "m"  # highest key in range
                old: true
            #liveReadStream.on "data", (data) ->
            #    console.log "live", data
            liveReadStream.pipe logger

            delay 5000, () ->
                console.log "writing again ***********"
                writeStream2 = subDb.createWriteStream()
                writeStream2 = writeStream2.on 'error', (err) ->
                    console.log "******error writing db stream", err

                p = queryStream "level"
                p = p.pipe writeStream2

                delay 5000, () ->

    tail: true      # get live updates
    min : "level"   # lowest key in range
    max : "levele"  # highest key in range
    old : false     # false to get only new records
    reverse: true   # stream in reverse (only applies to old records)


###
