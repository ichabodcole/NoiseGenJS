(function() {
  var mediaElement;

  mediaElement = document.createElement('audio');

  describe("NoiseGen", function() {
    before(function() {
      this.ctx = allen.getAudioContext();
      return this.gainNode = this.ctx.createGain();
    });
    beforeEach(function() {
      return this.noiseGen = new NoiseGen(this.ctx);
    });
    describe('constructor', function() {
      return it("should be an instance of NoiseGen", function() {
        return expect(this.noiseGen).to.be["instanceof"](NoiseGen);
      });
    });
    describe('properties', function() {
      it('should have an input property of type AudioNode', function() {
        return expect(allen.isAudioNode(this.noiseGen.input)).to.equal(true);
      });
      it('should have an output property of type AudioNode', function() {
        return expect(allen.isAudioNode(this.noiseGen.output)).to.equal(true);
      });
      return it('should have a type property defaulted to "brown"', function() {
        return expect(this.noiseGen.type).to.equal('brown');
      });
    });
    describe('start', function() {
      return it('should have a start method', function() {
        return expect(this.noiseGen).to.respondTo('start');
      });
    });
    describe('stop', function() {
      return it('should have a stop method', function() {
        return expect(this.noiseGen).to.respondTo('stop');
      });
    });
    describe('connect', function() {
      it('should have a method connect that takes and AudioNode', function() {
        var connect,
          _this = this;
        connect = function() {
          return _this.noiseGen.connect(_this.gainNode);
        };
        return expect(connect).to.not["throw"]();
      });
      return it('should take a web audio component instance', function() {
        var connect,
          _this = this;
        connect = function() {
          return _this.noiseGen.connect(new NoiseGen(_this.ctx));
        };
        return expect(connect).to.not["throw"]();
      });
    });
    return describe('disconnect', function() {
      return it('should have a method disconnect', function() {
        return expect(this.noiseGen).to.respondTo('disconnect');
      });
    });
  });

}).call(this);
