###
NoiseGenJS
v1.1
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
  constructor: (ctx, @type="brown")->
    @input  = ctx.createGain()
    @output = ctx.createGain()

    @instanceCount = 0
    @bufferSize = 4096
    @baseName = "NoiseGen_audioprocess_0"
    @namespace = null
    @audioProcessor = null

    @_createInternalNodes(ctx)
    @_routeNodes()
    @setNoiseType(@type)
    # A unique namespace is created for the processor loop
    # in the event there are multiple NoiseGens running at the same time.
    @_createProcessorNamespace()

  _createInternalNodes: (ctx)->
    @audioProcessor = ctx.createScriptProcessor(@bufferSize, 1, 2)

  _routeNodes: ->
    @input.connect(@output)
    @audioProcessor.connect(@output)

  _createProcessorNamespace: ->
    @namespace =  @baseName + @instanceCount
    # check if an object with the current namespace name exists
    # if it already exists create a new namespace ending with a number
    # one higher than the current namespace.
    if typeof(window[@namespace]) != "undefined"
      while window[@namespace]
        @instanceCount++
        @namespace = baseName + @instanceCount
        # namespaces max out at 10 and then get overwritten for the sake
        # of processor speed.
        if @instanceCount >= 9 then break

  _createProcessorLoop: ->
    # create a reference to this so we can pass it into
    # the onaudioprocess event
    # self = @
    # The onaudioprocess callback must be added to the global
    # namespace or it won't get called.
    @audioProcessor.onaudioprocess = window[@namespace] = (e)=>
      outBufferL = e.outputBuffer.getChannelData(0)
      outBufferR = e.outputBuffer.getChannelData(1)
      i = 0
      while i < @bufferSize
        outBufferL[i] = @noise.update()
        outBufferR[i] = @noise.update()
        i++
      return null
    return null

  #Public Methods
  start: ->
    @_createProcessorLoop()

  stop: ->
    @audioProcessor.onaudioprocess = window[@namespace] = null

  connect: (dest)->
    @output.connect(if dest.input then dest.input else dest)

  disconnect: ->
    @output.disconnect()

  setNoiseType: (@type)->
    @noise = NoiseFactory.create(@type)

# Noise Factory returns a the give type of noise generator.
class NoiseFactory
  # constructor: ->
  #   @noise
  #   @type

  @create: (type)->
    if type == "white"
      noise = new WhiteNoise()
    else if type == "pink"
      noise = new PinkNoise()
    else if type == "brown"
      noise = new BrownNoise()
    else
      console.log("Defaulting to Brown noise")
      noise = new BrownNoise()

    return noise

#Abstract Noise Class
class Noise
  update: ->
    return "Not implemented"

  random: ->
    Math.random() * 2 - 1


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
