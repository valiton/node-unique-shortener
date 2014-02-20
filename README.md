# unique-shortener

A redis-backed URL-shortener which only generates 1 short-url per url

## Installation

    $ npm install git@github.com:valiton/node-unique-shortener.git --save

## Usage
	config =
	  validation: no
	  counterKey: 'unique-shortener-counter'

	shortener = new UniqueShortener config
    shortener.xinit primaryRedisClient, secondaryRedisClient
	shortener.shorten 'http://example.com', (err, result) ->
		console.log JSON.stringify result // returns {key: '231aX', 'createdNew': false}



### Config

validation: defines if the input string should be validated as a valid url
counterKey: the name of the key in redis database where the counter should be stored

### Methods

#### init(mongodb, redisClient)
The shortener uses mongodb for primary data store and redis for caching. The init-Method requires a mongodb client connection and a standard redis client.

Usage:

	MongoClient = require('mongodb').MongoClient
	MongoClient.connect 'mongodb://localhost:27017/unique-shortener-test', (err, mdb) ->
		redisdb = redis.createClient()
		redisdb.select(6)
		shortener.init mdb, redisdb
 

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

### 0.2.0

* Initial version

## Authors

* Gleb Kotov