# run this from your project-directory like this:
# $ coffee examples/unique-shortener.coffee

redis             = require 'redis'
UniqueShortener   = require "#{process.cwd()}/lib/unique-shortener"

config =
  validation: no
  counterKey: 'unique-shortener-counter'

shortener = new UniqueShortener config
primdb = redis.createClient()
primdb.select(0)

secdb = redis.createClient()
secdb.select(1)

shortener.init primdb, secdb

shortener.shorten 'http://catforce.de', (err, result) ->
  console.log JSON.stringify result


