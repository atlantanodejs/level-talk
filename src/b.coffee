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


logger = eventStream.mapSync (doc) ->
    console.log typeof doc, doc
    doc

trimDescription = eventStream.mapSync (doc) ->
    isLong = doc.description.length > 60
    doc.description = doc.description.substr(0, 60)
    doc.description += "..."  if isLong
    doc


module.exports = queryStream = (term) ->

    uri = "http://npmsearch.com/query?fl=name,description,homepage&rows=30&sort=rating+desc&q="
    uri = uri + term

    p = hyperquest uri
    p = p.pipe process.stdout
    p = p.pipe JSONStream.parse "response.docs.*"
    p = p.pipe trimDescription
    #p = p.pipe logger



if require.main is module
    queryStream "leveldb"
