(function() {
  describe("NoiseGen", function() {
    before(function() {
      this.ctx = allen.getAudioContext();
      return this.gainNode = this.ctx.createGain();
    });
    beforeEach(function() {
      window.NoiseGenProcessors = null;
      return this.noiseGen = new NoiseGen(this.ctx);
    });
    describe('constructor', function() {
      it("should be an instance of NoiseGen", function() {
        return expect(this.noiseGen).to.be["instanceof"](NoiseGen);
      });
      return it('should increate the global NoiseGenProcessors by 1', function() {
        var processorCount;
        processorCount = window.NoiseGenProcessors.length;
        return expect(processorCount).to.equal(1);
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
    describe('remove', function() {
      it('should have a remove method', function() {
        return expect(this.noiseGen).to.respondTo('remove');
      });
      return it('should descrease the global NoiseGenProcessors length by 1', function() {
        var processorCountAfter, processorCountBefore;
        processorCountBefore = window.NoiseGenProcessors.length;
        this.noiseGen.remove();
        processorCountAfter = window.NoiseGenProcessors.length;
        return expect(processorCountAfter).to.equal(processorCountBefore - 1);
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
    describe('disconnect', function() {
      return it('should have a method disconnect', function() {
        return expect(this.noiseGen).to.respondTo('disconnect');
      });
    });
    return describe('setNoiseType', function() {
      it('should change the noise type', function() {
        this.noiseGen.setNoiseType('white');
        return expect(this.noiseGen.type).to.equal('white');
      });
      return it('should create a new noise object with an update method', function() {
        var update,
          _this = this;
        this.noiseGen.setNoiseType('pink');
        update = function() {
          return _this.noiseGen.noise.update();
        };
        return expect(update).to.not["throw"]();
      });
    });
  });

}).call(this);
