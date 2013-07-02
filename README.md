NoiseGenJS
==========

A Javascript/CoffeeScript library for generating several types of ambient noise using the Web Audio API. <a target="_blank" href="http://htmlpreview.github.com/?https://github.com/ichabodcole/NoiseGenJS/blob/master/example/app.html" title="NoiseGenJS Demo">DEMO</a>

### Basic Usage
    // Create a new AudioContext to connect to
    var context = new webkitAudioContext()

    // Create a NoiseGen instance. The noise type can be "brown", "white" or "pink". The type default is "brown".
    noiseGen = new NoiseGen(context, [noiseType="brown", "white", "pink"])

    // Change the noise type.
    noiseGen.setType("pink")

    // Create a new gain node to control volume
    var volume = context.createGain();

    // Connect to the NoiseGen node to the gain node
    noiseGen.connect(volume)
    
    // Connect the gain node to the context output.
    volume.connect(context.destination)

    // Control volume like this
    volume.gain.value = .8

    // Finally
    noiseGen.start()