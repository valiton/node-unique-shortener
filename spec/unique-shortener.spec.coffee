require 'jasmine-matchers'
async             = require 'async'
RedisMock         = require './redis-mock.spec'
MongoMock         = require './mongo-mock.spec'
UniqueShortener   = require "#{process.cwd()}/lib/unique-shortener"

describe 'UniqueShortener', ->
  # tests for init()
  describe 'init', ->

    it 'should initialize the config', ->
      config =
        validation: no
      shortener = new UniqueShortener config
      expect(shortener.config.validation).toBeFalsy()

    it "should create collection urls ", ->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock

      mongoClientcollectionSpy = spyOn(mongoMock, 'collection').andCallThrough()

      shortener.init mongoMock, redisMock
      expect(mongoClientcollectionSpy).toHaveBeenCalledWith("urls");

    it "should ensure indexes on collection urls without index ", ->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock

      MongoCollection = 
        ensureIndex : (fields, params, cb) ->
          cb()


      mongoCollectionMockensureIndexSpy = spyOn(MongoCollection, 'ensureIndex').andCallThrough()
      mongoClientcollectionSpy = spyOn(mongoMock, 'collection').andReturn(MongoCollection)

      shortener.init mongoMock, redisMock
      expect(mongoClientcollectionSpy).toHaveBeenCalledWith("urls");

      expect(mongoCollectionMockensureIndexSpy.callCount).toEqual 2

      expect(mongoCollectionMockensureIndexSpy.calls[0].args[0]).toEqual({key : 1});
      expect(mongoCollectionMockensureIndexSpy.calls[0].args[1]).toEqual({});

      expect(mongoCollectionMockensureIndexSpy.calls[1].args[0]).toEqual({url : 1});
      expect(mongoCollectionMockensureIndexSpy.calls[1].args[1]).toEqual({});

    it "should call callback ", (done)->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock

     
      shortener.init mongoMock, redisMock, (err)->
        expect(err).toBeNull()
        done()
      
      
  describe 'shorten', ->
    it 'should return short key', ->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock
      shortener.init mongoMock, redisMock
      shortener.shorten 'http://valiton.com', (err, result) ->
        console.log "err" ,err
        console.log "result" ,result

        expect(result.key).toEqual 'gChNU6Pd4cG'


    it 'should return same key for already shorted url', ->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock
      shortener.init mongoMock, redisMock
      shortener.shorten 'http://valiton.com', (err, result) ->
        shortener.shorten 'http://valiton.com', (err, result2) ->
          expect(result.key).toEqual result2.key


    it 'should decline invalid url', ->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock
      shortener.init mongoMock, redisMock
      shortener.shorten 'alsökdfasölkdjf', (err, result) ->
        expect(err).not.toBeNull()
        expect(err.message).toEqual 'InvalidUrl'


    it 'should except invalid url on no validation', ->
      shortener = new UniqueShortener validation: no
      mongoMock = new MongoMock
      redisMock = new RedisMock
      shortener.init mongoMock, redisMock
      shortener.shorten 'alsökdfasölkdjf', (err, result) ->
        expect(err).toBeNull()
        expect(result.key).toEqual 'gJxWoGCz16k'


    it 'should shorten 100 urls and when resolve them all', (done) ->
      urls = {}

      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock
      shortener.init mongoMock, redisMock

      async.forEachLimit [0..99], 1, (i, cb) ->
        url = "http://www.valiton#{i}.de"
        shortener.shorten url, (err, result) ->
          expect(result.key).not.toBeUndefined()
          urls[url] = result.key
          cb()
      , (err) ->


        u = Object.keys urls
        async.forEachLimit u, 1, (url, cb2) ->
          shortener.resolve urls[url], (err, resUrl) ->
            expect(url).toEqual resUrl
            cb2()
        , (err) ->
          done()



  describe 'resolve', ->
    it 'should resolve the shorted url', ->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock
      shortener.init mongoMock, redisMock
      shortener.shorten 'http://valiton.com', (err, result) ->
        shortener.resolve result.key, (err, url) ->
          expect(url).toEqual 'http://valiton.com'


  describe "_createHash", ->
    it "should return a hash for a given url", ->
      shortener = new UniqueShortener
      urlHash = shortener._createHash("http://valiton.com")  
      expect(urlHash).toEqual "gChNU6Pd4cG"
    
    it "should return a hash with empty string", ->
      shortener = new UniqueShortener
      urlHash = shortener._createHash("")  
      expect(urlHash).toEqual "diqnhBzWHmy"
        


