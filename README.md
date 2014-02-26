# unique-shortener

A redis and MongoDB backed URL-shortener which only generates 1 short-url per url.
In a cluster setup it can be used with a central mongodb or mongodb replicatset and a redis on each client facing server for caching.

The mongoDB is used as permanent datastore.
The Redis is used for caching.

## Installation

    $ npm install unique-shortener --save

## Usage
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


### Config

validation: defines if the input string should be validated as a valid url

### Methods

#### init(mongodb, redisClient)
The shortener uses mongodb for primary data store and redis for caching. The init-Method requires a mongodb client connection and a standard redis client.

Usage:


##### shorten(url, callback)

Returns a result object with short-key and flag if the url was already existed or an error-object.

Example:

  shortener.shorten url, (err, result) ->
    console.log(result.key)
    console.log(result.createdNew)

  
Result object:

  {
    key:"oisdjf9",
    "createdNew": true
  }


##### resolve(key, callback)

Returns the resolved url if it exists.

Example:

  shortener.resolve key, (err, url) ->
    console.log(url)
    
Returns *NotFound* error if the key wasn't found



## Development

###### Clone application

    $ git clone https://github.com/valiton/node-unique-shortener.git


###### Install all modules

    $ npm install

###### Run jasmine tests 

runs **grunt prod** task in background

    $ npm test

## Release History

### 0.4.1

* Bugfixes
* update Documentation
* add grunt dev task for outreload of tests


### 0.4.0

* Added index to MongoDb

### 0.3.0

* rebuild shortening with hashing

### 0.2.0

* created version with mongo as primary storage and redis as mongo cache

### 0.1.0

* Initial version

## Authors

* Gleb Kotov
* Alexander Stautner
* Benedikt Weiner

## License
Copyright (c) 2013 Valiton GmbH
Licensed under the MIT license.