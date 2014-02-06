_       = require 'lodash'
base62  = require 'base62'

module.exports = class UniqueShortener

  httpRegex = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i


  ###*
   * create a new Test_lib instance,
   *
   * @memberOf global
   *
   * @constructor
   * @param {object} config read more about config options in README
   * @this {Test_lib}
  ###
  constructor: (@config) ->
    @config = _.merge
      validation: yes
      counterKey: 'unique-shortener-counter'
    , @config


  ###*
   * initalize the Test_lib-Instance
   *
   * @function global.Test_lib.prototype.init
   * @returns {this} the current instance for chaining
  ###
  init: (@mongo, @redis) ->
    # TODO insure counter



  shorten: (url, cb) ->
    if @config.validation and not httpRegex.test url
      return cb new Error('InvalidUrl')

    # Look up the url first
    @_findOne
      url: url
    , (err, record) =>
      # We found one existing, so return it back
      if not err? and record?
        return cb null,
          key: record.key
          createdNew: no

      # Save new url
      @_incCounter (err, counter) =>
        return cb(err) if err?

        key = base62.encode counter
        @_insert
          key: key
          url: url
        , (err, record) =>
          return cb(err) if err?
          return cb null,
            key: key
            createdNew: yes


  resolve: (key, cb) ->
    @_findOne
      key: key
    , (err, record) ->
      return cb err if err?
      return cb new Error('NotFound') unless record?
      cb null, record.url



  _findOne: (q, cb) ->
    @redis.get JSON.stringify(q), (err, result) =>
      if not err? and result?
        return cb null, JSON.parse(result)

      @mongo.collection('urls').findOne q, {}, (err, result) =>
        if err? or not result?
          return cb err, result
        else
          # Cache it
          @redis.set JSON.stringify(q), JSON.stringify(result), (err) ->
            return cb null, result


  _insert: (q, cb) ->
    @mongo.collection('urls').insert q, (err, result) ->
      cb err, result


  _incCounter: (cb) ->
    @mongo.collection('counter').update
      counter: true
    ,
      '$inc':
        value: 1
    , (err, count) =>
      return cb(err) if err?
      if count is 0
        # no counter record insert
        # create one and then increment it
        @mongo.collection('counter').insert
          counter: true
          value: 0
        , (err, record) =>
          return cb(err) if err?
          # @_incCounter cb
      else
        @mongo.collection('counter').findOne
          counter: true
        , {}, (err, record) ->
          if err? or not record?
            return cb err, record
          return cb null, record.value
        





