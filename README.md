# unique-shortener

a redis-backed URL-shortener which only generates 1 short-url per url

## Installation

    $ npm install git+ssh://git@gitlab-openvpn:bigdata/unique-shortener.git --save

## Benutzung

    config = {}
    UniqueShortener = require 'unique-shortener'
    uniqueshortener = new UniqueShortener config
    uniqueshortener.init()


## Beispiele

siehe Folder **examples**

## Api-Dokumentation

**doc/index.html** im Browser öffnen

### Config

#### config.xxx

...

### Methoden

#### init

Muss mit der Konfiguration **config** aufgerufen werden

## Entwicklung

###### Applikation klonen

    $ git clone git@gitlab-openvpn:bigdata/unique-shortener.git


###### Alle Module installieren

    $ npm install

###### Jasmine Tests laufen lassen 

lässt intern **grunt vihbm** laufen - definiert im scripts-block der package.json

    $ npm test

## Release History

### 0.1.0

* Initiale Version

## Autoren

* Bastian Behrens