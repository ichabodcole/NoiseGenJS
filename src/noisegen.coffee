###
NoiseGenJS
v0.2.2
Author: Cole Reed
ichabodcole (AT) gmail.com

Copyright (c) 2013 Cole Reed, https://github.com/ichabodcole/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###
class NoiseGen
  @STOPPED = 0
  @PLAYING = 1

  @WHITE_NOISE = "white"
  @BROWN_NOISE = "brown"
  @PINK_NOISE  = "pink"
  @SILENCE     = "silence"

  constructor: (ctx, @noiseType=NoiseGen.BROWN_NOISE)->
    @input  = ctx.createGain()
    @output = ctx.createGain()

    @instanceCount = 0
    @bufferSize = 4096
    @audioProcessor = null
    @noise = null
    @state = @STOPPED
    @timeout = null
    @bufferTimeout = 250

    @_createInternalNodes(ctx)
    @_routeNodes()

  _createInternalNodes: (ctx)->
    @audioProcessor = @_storeProcessor(ctx.createScriptProcessor(@bufferSize, 1, 2))

  _routeNodes: ->
    @input.connect(@output)

  # Create an array attached to the global obect.
  # The ScripProcessor must be added to the global object or it will
  # get get garbage collected to soon.
  _getProcessorIndex: ->
    window.NoiseGenProcessors = window.NoiseGenProcessors ? []

  # Store the processor node in the global processor array.
  _storeProcessor: (node)->
    pIndex = @_getProcessorIndex()
    node.id = pIndex.length
    pIndex[node.id] = node
    return node

  # Remove the processor node from the global processor array.
  _removeProcessor: (node)->
    pIndex = @_getProcessorIndex()
    delete pIndex[node.id]
    pIndex.splice(node.id, 1)
    return node

  _createProcessorLoop: ->
    @audioProcessor.onaudioprocess = (e)=>
      outBufferL = e.outputBuffer.getChannelData(0)
      outBufferR = e.outputBuffer.getChannelData(1)
      i = 0
      while i < @bufferSize
        outBufferL[i] = @noise.update()
        outBufferR[i] = @noise.update()
        i++
      return null
    return null

  _setNoiseGenerator: (noiseType)->
    @noise = NoiseFactory.create(noiseType)

  # We create a small delay between the stop method call and the disconnect to
  # allow time for the audio buffer to fill will silence
  _createProcessorTimeout: ->
    @timeout = setTimeout =>
      if @state == @STOPPED
        @audioProcessor.disconnect()
    , @bufferTimeout

  _clearProcessorTimeout: ->
    if @timeout != null
      clearTimeout(@timeout)

  #Public Methods
  start: ->
    if @state == @STOPPED
      @_clearProcessorTimeout()
      @_setNoiseGenerator(@noiseType)
      @_createProcessorLoop()
      @audioProcessor.connect(@output)
      @state = @PLAYING

  stop: ->
    if @state == @PLAYING
      @_setNoiseGenerator(NoiseGen.SILENCE)
      @_createProcessorTimeout()
      @state = @STOPPED

  remove: ->
    @_removeProcessor(@audioProcessor)

  connect: (dest)->
    @output.connect(if dest.input then dest.input else dest)

  disconnect: ->
    @output.disconnect()

  setNoiseType: (@noiseType)->
    @_setNoiseGenerator(@noiseType)

# Noise Factory returns a the give type of noise generator.
class NoiseFactory

  @create: (type)->
    noise = switch type
      when NoiseGen.WHITE_NOISE
        new WhiteNoise()
      when NoiseGen.PINK_NOISE
        new PinkNoise()
      when NoiseGen.BROWN_NOISE
        new BrownNoise()
      when NoiseGen.SILENCE
        new Silence()
      else
        new BrownNoise()

    return noise

#Abstract Noise Class
class Noise
  update: ->
    return "Not implemented"

  random: ->
    Math.random() * 2 - 1

class Silence extends Noise
  update: ->
    return 0


class WhiteNoise extends Noise
  update: ->
    @random()


class BrownNoise extends Noise
  constructor: ->
    @base = 0

  update: ->
    r = @random() * 0.1
    @base += r
    if @base < -1 or @base > 1
      @base -= r
    @base


class PinkNoise extends Noise
  constructor: ->
    @alpha = 1
    @poles = 5
    @multipliers = @zeroFill([], @poles)
    @values      = @zeroFill([], @poles)
    @fillArrays()

  fillArrays: ->
    a = 1
    for i in @poles
      a = (i - @alpha / 2) * a / (i+1)
      @multipliers[i] = a

    for i in (@poles * 5)
      @update()

  zeroFill: (myArray, fillSize)->
    for i in fillSize
      myArray[i] = 0

  update: ->
    x = @random() * 1

    for i in @poles
      x -= @multipliers[i] * @values[i]

    @values.unshift(x)
    @values.pop()
    return x * 0.5

# Setup AMD or global object
if typeof define == 'function' && define.amd
  define ->
    return NoiseGen
else
  if typeof window == "object" && typeof window.document == "object"
    window.NoiseGen = NoiseGen