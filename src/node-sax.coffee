sax = require 'sax'

nodeStack = []

currentNode = () ->
  nodeStack[nodeStack.length - 1] if nodeStack.length > 0

createStream = () ->
  stream = sax.createStream true,
    strict: false

  stream.nodeReadyListeners = {}

  stream.on 'error', (err) ->
    console.error err

  stream.on 'opentag', (tag) ->
    #console.log arguments
    current = currentNode()

    if current or stream.nodeReadyListeners[tag.name]

      next_node =
        $attributes: tag.attributes
        $tagName: tag.name

      if current
        if current[tag.name]
          if not (current[tag.name] instanceof Array)
            current[tag.name] = [ current[tag.name] ]
          current[tag.name].push next_node
        else
          current[tag.name] = next_node
      

      nodeStack.push next_node

  stream.on 'text', (text) ->
    currentNode()['$text'] = text if currentNode()

  stream.on 'cdata', (text) ->
    node = currentNode()
    if node
      currentText = node['$text'] || ""
      node['$text'] = currentText + text

  stream.on 'closetag', () ->
    #console.log arguments
    if currentNode()
      current = nodeStack.pop()
      cb = stream.nodeReadyListeners[current.$tagName]
      cb(current) if cb

  stream.onNodeReady = (tag, cb) ->
    stream.nodeReadyListeners[tag] = cb
 
  stream

module.exports =
  createStream: createStream
