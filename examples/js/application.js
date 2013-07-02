(function() {
  var context, gain, noiseGen, started;

  context = new webkitAudioContext();

  noiseGen = new NoiseGen(context, "white");

  gain = context.createGain();

  noiseGen.connect(gain);

  gain.connect(context.destination);

  started = false;

  $(".btn").click(function(e) {
    if (started === false) {
      noiseGen.start();
      return started = true;
    }
  });

  $("#btn-white").click(function() {
    return noiseGen.setNoiseType("white");
  });

  $("#btn-brown").click(function() {
    return noiseGen.setNoiseType("brown");
  });

  $("#btn-pink").click(function() {
    return noiseGen.setNoiseType("pink");
  });

  $("#sldr-volume").change(function(e) {
    var volume;
    volume = e.target.value;
    return gain.gain.value = volume / 100;
  });

  $("#sldr-volume").change();

}).call(this);
