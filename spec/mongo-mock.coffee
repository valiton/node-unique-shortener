class MongoCollection
  constructor: () ->
    @data = []
    @counter = 0


  insert: (q, cb) ->
    if q.counter
      @counter = q.value
    else
      @data.push q
    cb()


  findOne: (q, cons, cb) ->
    if q.counter
      return cb null, {counter: true, value: @counter}

    if q.key?
      for d in @data
        if d.key is q.key
          return cb null, d
      return cb new Error('NotFound')

    if q.url?
      for d in @data
        if d.url is q.url
          return cb null, d
      return cb new Error('NotFound')

    return cb new Error('NotFound')


  update: (q, command, cb) ->
    @counter += 1
    cb()

  ensureIndex : (fields, params, cb) ->
   



module.exports = class MongoMock
  
  constructor: () ->
    @cols = {}


  collection: (name) ->
    if not @cols[name]?
      @cols[name] = new MongoCollection
    return @cols[name]