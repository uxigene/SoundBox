module.exports = (grunt) ->
  grunt.initConfig (

    # read package.json
    pkg: grunt.file.readJSON "package.json"

    # watch conf section
    watch:
      files: [
        "Gruntfile.coffee"
        "coffee/**/*.coffee"
      ]
      tasks: ["default"]
      options:
        livereload: true
        nospawn: false

    # coffee conf section
    coffee:
      compile:
        files: [
          (
            expand: true
            cwd: "coffee"
            src: [
              "**/*.coffee"
            ]
            dest: "assets/js"
            ext: ".js"
          )
        ]
        options:
          sourceMap: true
          bare: true

    # clean conf section
    clean:
      dev: [
        "assets/js"
      ]
      build: [
        "assets/js"
        "assets/dist/js"
      ]

    # uglify conf section
    uglify:
      options:
        report: 'gzip'
      dist:
        files:
          'assets/dist/js/sound-box.min.js': 'assets/js/sound-box.js'
  )

  # load tasks
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-uglify"

  # register tasks
  grunt.registerTask "default", [
    "clean:dev"
    "coffee"
  ]

  grunt.registerTask "build", [
    "clean:build"
    "coffee"
    "uglify"
  ]