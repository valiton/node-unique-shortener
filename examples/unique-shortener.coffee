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
redisdb.select(5)

MongoClient.connect 'mongodb://localhost:27017/unique-shortener-test', (err, db) ->
  shortener.init db, redisdb

  shortener.shorten 'http://catforce.de', (err, result) ->
    console.log JSON.stringify result