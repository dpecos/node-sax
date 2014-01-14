fs = require "fs"
sax = require "../"

stream = sax.createStream()

stream.onNodeReady "person", (node) ->
  console.log node

stream.on 'end', () ->
  console.log "Done!"

fs.createReadStream("test_person.xml").pipe(stream)
