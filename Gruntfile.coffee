# Basic vInsight-lib-module configuration
module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    coffeelint:
      app: ["src/**/*.coffee"]
      options:
        max_line_length:
          value: 1000
          level: "error"

    clean:
      before:
        src: ["coverage", "lib", "reports", "doc"]
      spec:
        src: ["spec-lib", "coverage/instrument"]

    coffee:
      compile:
        options:
          bare: true
        files: [
          {expand: true, cwd: './src', src: ['**/*.coffee'], dest: './lib', ext: '.js'},
          {expand: true, cwd: './spec', src: ['**/*.coffee'], dest: './spec-lib', ext: '.spec.js'}
        ]

    jasmine_node:
      projectRoot: "./spec-lib"
      jUnit:
        report: true
        savePath: "reports/"
        useDotNotation: true
        consolidate: false

    instrument :
      files : 'lib/*.js'
      options :
        basePath : './coverage/instrument/'

    storeCoverage :
      options :
        dir : './coverage'

    makeReport :
      src : './coverage/*.json'
      options :
        type : 'cobertura'
        dir : './coverage'
        print : 'detail'

    jsdoc:
      dist:
        src: ['lib/*.js'],
        options:
          destination: 'doc'

    replace:
      coverage:
        options:
          variables: '/lib/': '/coverage/instrument/lib/'
          prefix: ''
        files: [expand: true, cwd: './spec-lib', src: ['*.spec.js'], dest: './spec-lib', ext: '.spec.js']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.loadNpmTasks 'grunt-istanbul'
  grunt.loadNpmTasks 'grunt-replace'
  grunt.loadNpmTasks 'grunt-jsdoc'

  grunt.registerTask 'prod', ['clean:before','coffee', 'instrument', 'replace:coverage', 'jasmine_node', 'storeCoverage', 'makeReport', 'clean:spec', 'jsdoc']