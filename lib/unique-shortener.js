var UniqueShortener, base62, cityhash, _;

_ = require('lodash');

base62 = require('base62');

cityhash = require('cityhash');

module.exports = UniqueShortener = (function() {
  var httpRegex;

  httpRegex = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i;

  /**
   * create a new Test_lib instance,
   *
   * @memberOf global
   *
   * @constructor
   * @param {object} config read more about config options in README
   * @this {Test_lib}
  */


  function UniqueShortener(config) {
    this.config = config;
    this.config = _.merge({
      validation: true
    }, this.config);
  }

  /**
   * initalize the Test_lib-Instance
   *
   * @function global.Test_lib.prototype.init
   * @returns {this} the current instance for chaining
  */


  UniqueShortener.prototype.init = function(mongo, redis, cb) {
    var _this = this;
    this.mongo = mongo;
    this.redis = redis;
    return this.mongo.collection('urls').ensureIndex({
      key: 1
    }, {}, function(err, result) {
      if (err != null) {
        return typeof cb === "function" ? cb(err) : void 0;
      } else {
        return _this.mongo.collection('urls').ensureIndex({
          url: 1
        }, {}, function(err, result) {
          if (err != null) {
            return typeof cb === "function" ? cb(err) : void 0;
          } else {
            return typeof cb === "function" ? cb(null) : void 0;
          }
        });
      }
    });
  };

  UniqueShortener.prototype.shorten = function(url, cb) {
    var _this = this;
    if (this.config.validation && !httpRegex.test(url)) {
      return cb(new Error('InvalidUrl'));
    }
    return this._findOne({
      url: url
    }, function(err, record) {
      var key;
      if ((err == null) && (record != null)) {
        return cb(null, {
          key: record.key,
          createdNew: false
        });
      } else {
        key = _this._createHash(url);
        return _this._insert({
          key: key,
          url: url
        }, function(err, record) {
          if (err != null) {
            return cb(err);
          }
          return cb(null, {
            key: key,
            createdNew: true
          });
        });
      }
    });
  };

  UniqueShortener.prototype.resolve = function(key, cb) {
    return this._findOne({
      key: key
    }, function(err, record) {
      if (err != null) {
        return cb(err);
      }
      if (record == null) {
        return cb(new Error('NotFound'));
      }
      return cb(null, record.url);
    });
  };

  UniqueShortener.prototype._findOne = function(q, cb) {
    var _this = this;
    return this.redis.get(JSON.stringify(q), function(err, result) {
      if ((err == null) && (result != null)) {
        return cb(null, JSON.parse(result));
      }
      return _this.mongo.collection('urls').findOne(q, {}, function(err, result) {
        if ((err != null) || (result == null)) {
          return cb(err, result);
        } else {
          return _this.redis.set(JSON.stringify(q), JSON.stringify(result), function(err) {
            if (err != null) {
              return cb(err);
            }
            return cb(null, result);
          });
        }
      });
    });
  };

  UniqueShortener.prototype._insert = function(q, cb) {
    return this.mongo.collection('urls').insert(q, function(err, result) {
      return cb(err, result);
    });
  };

  UniqueShortener.prototype._createHash = function(url) {
    var encodedHash, hash;
    hash = cityhash.hash64(url).value;
    encodedHash = base62.encode(hash);
    return encodedHash;
  };

  return UniqueShortener;

})();
