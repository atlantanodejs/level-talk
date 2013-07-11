
hyperspace = require "hyperspace"
#hyperglue = require "hyperglue"
fs = require "fs"

html = fs.readFileSync __dirname + "/article.html"

module.exports = () ->

    hyperspace html, (row) ->
        data =
            ".name": row.name
            ".url": row.homepage
            ".link a":
                _text: row.name
                href: row.homepage
            ".description": row.description
        data
