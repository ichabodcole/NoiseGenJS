###
NoiseGenJS
v1.0
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
class window.NoiseGen
  constructor: (context, type="brown")->
    @instanceCount = 0
    @userVolume = 1
    @defaultfadeLength = 2
    @bufferSize = 4096

    @context = context
    @setNoiseType(type)
    @audioProcessor = context.createScriptProcessor(@bufferSize, 1, 2)
    @masterGain     = context.createGain()

    @init()

  init: ->
    # A unique namespace is created for the processor loop
    # in the event there are multiple NoiseGens running at the same time.
    @createProcessorNamespace()
    @createProcessorLoop()
    @audioProcessor.connect(@masterGain)

  setNoiseType: (type)->
    @noise = NoiseFactory.create(type)

  createProcessorNamespace: ->
    baseName = "NoiseGen_audioprocess_0"
    @namespace =  baseName + @instanceCount
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

  createProcessorLoop: ->
    # create a reference to this so we can pass it into
    # the onaudioprocess event
    self = this
    # The onaudioprocess callback must be added to the global
    # namespace or it won't get called.
    @audioProcessor.onaudioprocess = window[@namespace] = (e)->
      outBufferL = e.outputBuffer.getChannelData(0)
      outBufferR = e.outputBuffer.getChannelData(1)
      i = 0
      while i < @bufferSize
        outBufferL[i] = self.noise.update()
        outBufferR[i] = self.noise.update()
        i++
      return null
    return null

  setGain: (gain)->
    @masterGain.gain.value = gain

  #Public Methods
  getNode: ->
    return @masterGain

  setVolume: (volume)->
    @userVolume = volume
    @setGain(volume)
    null

  mute: (bool)->
    @setGain(0)
    null

  unmute: ->
    @setGain(@userVolume)
    null

  fadeTo: (value, fadeLength)->
    fadeLength = fadeLength || @defaultfadeLength
    currentTime = @context.currentTime
    #time the fade should complete
    fadeTime = currentTime + fadeLength
    #set the start time
    @masterGain.gain.setValueAtTime(@userVolume, currentTime)
    @masterGain.gain.linearRampToValueAtTime(value, fadeTime)

  fadeOut: (fadeLength)->
    fadeLength = fadeLength || @defaultfadeLength
    @fadeTo(0, fadeLength)

  fadeIn: (fadeLength)->
    fadeLength = fadeLength || @defaultfadeLength
    @fadeTo(@userVolume, fadeLength)

  end: ->
    @stop()

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
