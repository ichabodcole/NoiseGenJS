context = new webkitAudioContext()
noise = new NoiseGen(context, "white")
noiseNode = noise.getNode()

newGain = context.createGain()

noiseNode.connect(newGain)
newGain.connect(context.destination)

started = false

$(".btn").click (e)->
    if(started == false)
        noise.start()
        started = true

$("#btn-white").click ->
    noise.setNoiseType("white")

$("#btn-brown").click ->
    noise.setNoiseType("brown")

$("#btn-pink").click ->
    noise.setNoiseType("pink")

$("#sldr-volume").change (e)->
    volume = e.target.value
    noise.setVolume(volume/100)
