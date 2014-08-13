_ = require 'underscore'

coffeeRename = (destBase, destPath) ->
  destPath = destPath.replace 'src/',''
  destBase + destPath.replace /\.coffee$/, '.js'

module.exports = (grunt) ->

  filterGrunt = ->
    gruntFiles = require("matchdep").filterDev("grunt-*")
    _.reject gruntFiles, (x) -> x is 'grunt-cli'

  filterGrunt().forEach grunt.loadNpmTasks

  grunt.initConfig 
    #release:
    #  options:
    coffee:
      compile:
        options:
          sourceMap: true

        files: grunt.file.expandMapping(['src/**/*.coffee'], 'lib/', {rename: coffeeRename })
 
    watch:
      scripts:
        files: ['src/*.coffee','src/methods/*.coffee','src/schemas/*.coffee']
        tasks: 'coffee'

    env:
      test:
        NODE_ENV: "test"

    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
        src: ['test/**/*-tests.coffee']

    mochacov:
      options:
        coveralls:
          repoToken: ""
        require: ['coffee-script/register','should']
      all: ['test/**/*-tests.coffee']

  grunt.registerTask "testandcoverage", [
    'env:test'
    'mochaTest:test'
    'mochacov'
  ]

  grunt.registerTask 'deploy', [
    'test'
    'release'
  ]


  grunt.registerTask 'default', 'watch'
