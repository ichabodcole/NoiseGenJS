context = new webkitAudioContext()
noiseGen = new NoiseGen(context, "white")

gain = context.createGain()
noiseGen.connect(gain)
gain.connect(context.destination)


started = false

$(".btn").click (e)->
    if(started == false)
        noiseGen.start()
        started = true

$("#btn-white").click ->
    noiseGen.setNoiseType("white")

$("#btn-brown").click ->
    noiseGen.setNoiseType("brown")

$("#btn-pink").click ->
    noiseGen.setNoiseType("pink")

$("#sldr-volume").change (e)->
    volume = e.target.value
    gain.gain.value = volume / 100

$("#btn-start").click ->
  noiseGen.start()

$("#btn-stop").click ->
  noiseGen.stop()

$("#sldr-volume").change()


