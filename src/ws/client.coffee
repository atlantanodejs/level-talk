
render = require("./render.js")()
render.on "element", (elem) ->
  elem.addEventListener "click", onclick = ->
    elem.classList.remove "summary"
    elem.removeEventListener "click", onclick


render.appendTo "#articles"
shoe = require("shoe")
shoe("/article-stream").pipe render
