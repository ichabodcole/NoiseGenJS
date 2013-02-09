// Generated by CoffeeScript 1.3.3
(function() {
  var BrownNoise, Noise, PinkNoise, WhiteNoise,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.NoiseFactory = (function() {

    function NoiseFactory() {
      this.noise;
      this.type;
    }

    NoiseFactory.prototype.create = function(type) {
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
