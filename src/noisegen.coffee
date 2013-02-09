class window.NoiseFactory
  constructor: ->
    @noise
    @type

  create: (type)->
    if type == "white"
      noise = new WhiteNoise()
    else if type == "pink"
      noise = new PinkNoise()
    else if type == "brown"
      noise = new BrownNoise()
    else
      console.log("Defaulting to Brown noise")
      noise = new BrownNoise()

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
    @multipliers = zeroFill(new Array(), @poles)
    @values      = zeroFill(new Array(), @poles)
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