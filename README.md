noisegenjs
==========

Library for generating random types of noise with the Web Audio API
Currently includes White, Brown, and Pink noise types

### Basic Usage
    `context = new.webkitAudioContext()
     noise1 = new NoiseGen(context, [noiseType="brown", "white", "pink"])
     noise1Node = ng1.getNode()
     noise.setVolume(0.5)
     ng1Node.connect(context.destination)`
