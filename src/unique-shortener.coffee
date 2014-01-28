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
  init: (@primRedis, @secRedis) ->


  shorten: (url, cb) ->
    if @config.validation and not httpRegex.test url
      return cb new Error('InvalidUrl')

    # Look up the url first
    @secRedis.get url, (err, key) =>
      if not err? and key?
        return cb null,
          key: key
          createdNew: no

      # Save new url
      @primRedis.incr @config.counterKey, (err, counter) =>
        cb err if err?

        key = base62.encode counter
        @primRedis.set key, url, (err) =>
          cb err if err?          
          @secRedis.set url, key, (err) =>
            cb err if err?
            return cb null,
              key: key
              createdNew: yes


  resolve: (key, cb) ->
    @primRedis.get key, (err, url) ->
      cb err if err?
      cb new Error('NotFound') unless url?
      cb null, url


