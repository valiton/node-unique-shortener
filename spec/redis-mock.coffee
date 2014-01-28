module.exports = class RedisMock
  
  constructor: (@config) ->
    @h = {}

  get: (key, cb) ->
    cb null, @h[key]


  set: (key, value, cb) ->
    @h[key] = value
    cb()


  incr: (key, cb) ->
    @h[key] = 0 unless @h[key]?
    @h[key] += 1
    cb null, @h[key]
