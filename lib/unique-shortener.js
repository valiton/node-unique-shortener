var UniqueShortener, base62, _;

_ = require('lodash');

base62 = require('base62');

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
      validation: true,
      counterKey: 'unique-shortener-counter'
    }, this.config);
  }

  /**
   * initalize the Test_lib-Instance
   *
   * @function global.Test_lib.prototype.init
   * @returns {this} the current instance for chaining
  */


  UniqueShortener.prototype.init = function(primRedis, secRedis) {
    this.primRedis = primRedis;
    this.secRedis = secRedis;
  };

  UniqueShortener.prototype.shorten = function(url, cb) {
    var _this = this;
    if (this.config.validation && !httpRegex.test(url)) {
      return cb(new Error('InvalidUrl'));
    }
    return this.secRedis.get(url, function(err, key) {
      if ((err == null) && (key != null)) {
        return cb(null, {
          key: key,
          createdNew: false
        });
      }
      return _this.primRedis.incr(_this.config.counterKey, function(err, counter) {
        if (err != null) {
          cb(err);
        }
        key = base62.encode(counter);
        return _this.primRedis.set(key, url, function(err) {
          if (err != null) {
            cb(err);
          }
          return _this.secRedis.set(url, key, function(err) {
            if (err != null) {
              cb(err);
            }
            return cb(null, {
              key: key,
              createdNew: true
            });
          });
        });
      });
    });
  };

  UniqueShortener.prototype.resolve = function(key, cb) {
    return this.primRedis.get(key, function(err, url) {
      if (err != null) {
        cb(err);
      }
      if (url == null) {
        cb(new Error('NotFound'));
      }
      return cb(null, url);
    });
  };

  return UniqueShortener;

})();
