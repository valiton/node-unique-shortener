_         = require 'lodash'
base62    = require 'base62'
cityhash  = require 'cityhash'

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
    , @config


  ###*
   * initalize the Test_lib-Instance
   *
   * @function global.Test_lib.prototype.init
   * @returns {this} the current instance for chaining
  ###
  init: (@mongo, @redis, cb) ->
    @mongo.collection('urls').ensureIndex {key: 1}, {}, (err, result) =>
      if err?
        cb? err
      else
        @mongo.collection('urls').ensureIndex {url: 1}, {}, (err, result) =>
          if err?
            cb? err
          else
            cb? null



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
      else
        key = @_createHash(url)
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
            return cb(err) if err?
            cb(null, result)


  _insert: (q, cb) ->
    @mongo.collection('urls').insert q, (err, result) ->
      cb err, result

  _createHash: (url)->
    hash = cityhash.hash64(url).value
    encodedHash = base62.encode hash
    encodedHash
