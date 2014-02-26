# $ coffee unique-shortener.coffee

redis           = require 'redis'
MongoClient     = require('mongodb').MongoClient
UniqueShortener = require "../lib/unique-shortener"

config =
  validation: no

shortener = new UniqueShortener config

redis = redis.createClient()
redis.select(0)

MongoClient.connect "mongodb://127.0.0.1:27017/unique-shortener", (err, mdb) =>
  if err?
    console.error err
  else
    shortener.init mdb, redis

    shortener.shorten 'http://www.valiton.com', (err, result) ->
      console.log JSON.stringify result


