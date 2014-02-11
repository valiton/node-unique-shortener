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
        counterKey: 'test-counter'
      shortener = new UniqueShortener config
      expect(shortener.config.validation).toBeFalsy()
      expect(shortener.config.counterKey).toEqual('test-counter')


  describe 'shorten', ->
    it 'should return short key', ->
      shortener = new UniqueShortener
      mongoMock = new MongoMock
      redisMock = new RedisMock
      shortener.init mongoMock, redisMock
      shortener.shorten 'http://valiton.com', (err, result) ->
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



