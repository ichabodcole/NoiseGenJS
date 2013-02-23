// Generated by CoffeeScript 1.3.3

/*
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
*/


(function() {
  var BrownNoise, Noise, NoiseFactory, PinkNoise, WhiteNoise,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.NoiseGen = (function() {

    function NoiseGen(context, type) {
      if (type == null) {
        type = "brown";
      }
      this.userVolume = 1;
      this.defaultfadeLength = 2;
      this.bufferSize = 4096;
      this.context = context;
      this.noiseFactory = NoiseFactory.create(type);
      this.audioProcessor = context.createScriptProcessor(this.bufferSize, 1, 2);
      this.masterGain = context.createGain();
      this.channelMerger = this.context.createChannelMerger();
      this.compressor = this.context.createDynamicsCompressor();
      return this.init();
    }

    NoiseGen.prototype.init = function() {
      this.createProcessorLoop();
      return this.audioProcessor.connect(this.masterGain);
    };

    NoiseGen.prototype.createProcessorLoop = function() {
      return this.audioProcessor.onaudioprocess = function(e) {
        var i, outBufferL, outBufferR;
        outBufferL = e.outputBuffer.getChannelData(0);
        outBufferR = e.outputBuffer.getChannelData(1);
        i = 0;
        while (i < this.bufferSize) {
          outBufferL[i] = this.noiseFactory.update;
          outBufferR[i] = this.noiseFactory.update;
          i++;
        }
      };
    };

    NoiseGen.prototype.getNode = function() {
      return this.masterGain;
    };

    NoiseGen.prototype.setVolume = function(volume) {
      this.userVolume = volume;
      this.setGain(volume);
      return null;
    };

    NoiseGen.prototype.mute = function(bool) {
      this.setGain(0);
      return null;
    };

    NoiseGen.prototype.unmute = function() {
      this.setGain(this.userVolume);
      return null;
    };

    NoiseGen.prototype.fadeTo = function(value, fadeLength) {
      var currentTime, fadeTime;
      fadeLength = fadeLength || this.defaultfadeLength;
      currentTime = this.context.currentTime;
      fadeTime = currentTime + fadeLength;
      this.masterGain.gain.setValueAtTime(this.userVolume, currentTime);
      return this.masterGain.gain.linearRampToValueAtTime(value, fadeTime);
    };

    NoiseGen.prototype.fadeOut = function(fadeLength) {
      fadeLength = fadeLength || this.defaultfadeLength;
      return this.fadeTo(0, fadeLength);
    };

    NoiseGen.prototype.fadeIn = function(fadeLength) {
      fadeLength = fadeLength || this.defaultfadeLength;
      return this.fadeTo(this.userVolume, fadeLength);
    };

    NoiseGen.prototype.end = function() {
      return this.stop();
    };

    return NoiseGen;

  })();

  NoiseFactory = (function() {

    function NoiseFactory() {}

    NoiseFactory.create = function(type) {
      var noise;
      if (type === "white") {
        return noise = new WhiteNoise();
      } else if (type === "pink") {
        return noise = new PinkNoise();
      } else if (type === "brown") {
        return noise = new BrownNoise();
      } else {
        console.log("Defaulting to Brown noise");
        return noise = new BrownNoise();
      }
    };

    return NoiseFactory;

  })();

  Noise = (function() {

    function Noise() {}

    Noise.prototype.update = function() {
      return "Not implemented";
    };

    Noise.prototype.random = function() {
      return Math.random() * 2 - 1;
    };

    return Noise;

  })();

  WhiteNoise = (function(_super) {

    __extends(WhiteNoise, _super);

    function WhiteNoise() {
      return WhiteNoise.__super__.constructor.apply(this, arguments);
    }

    WhiteNoise.prototype.update = function() {
      return this.random();
    };

    return WhiteNoise;

  })(Noise);

  BrownNoise = (function(_super) {

    __extends(BrownNoise, _super);

    function BrownNoise() {
      this.base = 0;
    }

    BrownNoise.prototype.update = function() {
      var r;
      r = this.random() * 0.1;
      this.base += r;
      if (this.base < -1 || this.base > 1) {
        this.base -= r;
      }
      return this.base;
    };

    return BrownNoise;

  })(Noise);

  PinkNoise = (function(_super) {

    __extends(PinkNoise, _super);

    function PinkNoise() {
      this.alpha = 1;
      this.poles = 5;
      this.multipliers = zeroFill(new Array(), this.poles);
      this.values = zeroFill(new Array(), this.poles);
      this.fillArrays();
    }

    PinkNoise.prototype.fillArrays = function() {
      var a, i, _i, _j, _len, _len1, _ref, _ref1, _results;
      a = 1;
      _ref = this.poles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        a = (i - this.alpha / 2) * a / (i + 1);
        this.multipliers[i] = a;
      }
      _ref1 = this.poles * 5;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        i = _ref1[_j];
        _results.push(this.update());
      }
      return _results;
    };

    PinkNoise.prototype.zeroFill = function(myArray, fillSize) {
      var i, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = fillSize.length; _i < _len; _i++) {
        i = fillSize[_i];
        _results.push(myArray[i] = 0);
      }
      return _results;
    };

    PinkNoise.prototype.update = function() {
      var i, x, _i, _len, _ref;
      x = this.random() * 1;
      _ref = this.poles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        x -= this.multipliers[i] * this.values[i];
      }
      this.values.unshift(x);
      this.values.pop();
      return x * 0.5;
    };

    return PinkNoise;

  })(Noise);

}).call(this);
