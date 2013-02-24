context = new webkitAudioContext()
noise = new NoiseGen(context, "brown")
noiseNode = noise.getNode()
noise.setVolume(0.5)

noise2 = new NoiseGen(context, "pink")
noiseNode2 = noise2.getNode()
noise2.setVolume(.5)

noise3 = new NoiseGen(context, "white")
noiseNode3 = noise3.getNode()
noise3.setVolume(0.3)

noise4 = new NoiseGen(context, "pink")
noiseNode4 = noise4.getNode()
noise4.setVolume(0.5)

newGain = context.createGain()

noiseNode.connect(newGain)
noiseNode2.connect(newGain)
noiseNode3.connect(newGain)
noiseNode4.connect(newGain)

newGain.connect(context.destination)
