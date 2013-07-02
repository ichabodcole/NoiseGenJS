mediaElement = document.createElement('audio')

describe "NoiseGen", ->
  before ->
    @ctx = allen.getAudioContext()
    @gainNode = @ctx.createGain()

  beforeEach ->
    @noiseGen = new NoiseGen(@ctx)

  describe 'constructor', ->
    it "should be an instance of NoiseGen", ->
      expect(@noiseGen).to.be.instanceof NoiseGen

  describe 'properties', ->
    it 'should have an input property of type AudioNode', ->
      expect(allen.isAudioNode(@noiseGen.input)).to.equal(true)

    it 'should have an output property of type AudioNode', ->
      expect(allen.isAudioNode(@noiseGen.output)).to.equal(true)

    it 'should have a type property defaulted to "brown"', ->
      expect(@noiseGen.type).to.equal('brown')

  describe 'start', ->
    it 'should have a start method', ->
      expect(@noiseGen).to.respondTo 'start'

  describe 'stop', ->
    it 'should have a stop method', ->
      expect(@noiseGen).to.respondTo 'stop'

  describe 'connect', ->
    it 'should have a method connect that takes and AudioNode', ->
      connect = =>
        @noiseGen.connect(@gainNode)
      expect(connect).to.not.throw()

    it 'should take a web audio component instance', ->
      connect = =>
        @noiseGen.connect(new NoiseGen(@ctx))
      expect(connect).to.not.throw()

  describe 'disconnect', ->
    it 'should have a method disconnect', ->
      expect(@noiseGen).to.respondTo 'disconnect'
