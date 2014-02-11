# run this from your project-directory like this:
# $ coffee examples/unique-shortener.coffee

redis             = require 'redis'
MongoClient       = require('mongodb').MongoClient
UniqueShortener   = require "#{process.cwd()}/lib/unique-shortener"

config =
  validation: no
  counterKey: 'unique-shortener-counter'

shortener = new UniqueShortener config
redisdb = redis.createClient()
redisdb.select(6)

MongoClient.connect 'mongodb://localhost:27017/unique-shortener-test', (err, db) ->

  shortener.init db, redisdb
  console.log "run shorten"
  shortener.shorten 'http://catforce2.de', (err, result) ->
    console.log JSON.stringify result


  # shortener.resolve '1', (err, url) ->
  #   console.log url