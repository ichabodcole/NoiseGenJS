# Note these tests may break in phantomJS,
# because of it does not yet support the web audio api.
describe "NoiseGen", ->
  before ->
    @ctx = allen.getAudioContext()
    @gainNode = @ctx.createGain()

  beforeEach ->
    window.NoiseGenProcessors = null
    @noiseGen = new NoiseGen(@ctx)

  describe 'constructor', ->
    it "should be an instance of NoiseGen", ->
      expect(@noiseGen).to.be.instanceof NoiseGen

    it 'should increate the global NoiseGenProcessors by 1', ->
      processorCount = window.NoiseGenProcessors.length
      expect(processorCount).to.equal 1

  describe 'properties', ->
    it 'should have an input property of type AudioNode', ->
      expect(allen.isAudioNode(@noiseGen.input)).to.equal(true)

    it 'should have an output property of type AudioNode', ->
      expect(allen.isAudioNode(@noiseGen.output)).to.equal(true)

    it 'should have a noiseType property defaulted to "brown"', ->
      expect(@noiseGen.noiseType).to.equal('brown')

  describe 'start', ->
    it 'should have a start method', ->
      expect(@noiseGen).to.respondTo 'start'

  describe 'stop', ->
    it 'should have a stop method', ->
      expect(@noiseGen).to.respondTo 'stop'

  describe 'remove', ->
    it 'should have a remove method', ->
      expect(@noiseGen).to.respondTo 'remove'

    it 'should descrease the global NoiseGenProcessors length by 1', ->
      processorCountBefore = window.NoiseGenProcessors.length
      @noiseGen.remove()
      processorCountAfter = window.NoiseGenProcessors.length
      expect(processorCountAfter).to.equal(processorCountBefore - 1)

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

  describe 'setNoiseType', ->
    it 'should change the noise type', ->
      @noiseGen.setNoiseType('white')
      expect(@noiseGen.noiseType).to.equal 'white'

    # This test is actually hitting the NoiseFactory and PinkNoise class
    # Ideally these should be tested separately...
    it 'should create a new noise object with an update method', ->
      @noiseGen.setNoiseType('pink')
      update = =>
        @noiseGen.noise.update()
      expect(update).to.not.throw()
