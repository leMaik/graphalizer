module.exports = function (grunt) {
    var uglifyFiles = [
        {
            'build/js/graphalizer.min.js': ['build/js/graphalizer.js', 'build/js/graphalizer-templates.js']
        }
    ];

    grunt.initConfig({
            pkg: grunt.file.readJSON('package.json'),
            coffee: {
                build: {
                    options: {
                        join: true
                    },
                    files: {
                        'build/js/graphalizer.js': ['src/coffee/observable.coffee', 'src/coffee/**/*.coffee']
                    }
                },
                debug: {
                    options: {
                        sourceMap: true,
                        join: true
                    },
                    files: {
                        'build/js/graphalizer.js': ['src/coffee/observable.coffee', 'src/coffee/**/*.coffee']
                    }
                }
            },
            uglify: {
                build: {
                    files: uglifyFiles,
                    options: {
                        compress: {
                            drop_console: true
                        }
                    }
                },
                debug: {
                    files: uglifyFiles,
                    options: {
                        beautify: true,
                        mangle: false,
                        compress: false
                    }
                }
            },
            less: {
                build: {
                    options: {
                        cleancss: true
                    },
                    files: {
                        "build/css/test.css": "src/css/test.less"
                    }
                },
                debug: {
                    options: {},
                    files: {
                        "build/css/test.css": "src/css/test.less"
                    }
                }
            },
            dot: {
                build: {
                    src: ['src/templates/**/*.doT'],
                    dest: 'build/js/graphalizer-templates.js',
                    options: {
                        variable: "__templates"
                    }
                }
            },
            clean: {
                before: [
                    'build'
                ],
                after: [
                    'build/js/*.js',
                    'build/templates',
                    'build/coffee',
                    '!**/*.min.js'
                ]
            },
            copy: {
                src: {
                    files: [
                        {
                            cwd: 'src/',
                            expand: true,
                            src: ['**', '!**/*.less', '!**/*.coffee'],
                            dest: 'build/',
                            dot: true
                        }
                    ]
                }
            },
            watch: {
                css: {
                    files: 'src/css/*.less',
                    tasks: ['copy:src', 'less', 'bell']
                },
                coffee: {
                    files: 'src/coffee/**/*.coffee',
                    tasks: ['coffee:debug', 'dot', 'uglify:debug', 'bell']
                },
                dot: {
                    files: 'src/templates/**/*.doT',
                    tasks: ['dot', 'uglify:debug', 'bell']
                },
                anything: {
                    files: ['src/**/*', '!**/*.less', '!**/*.coffee', '!**/*.doT'],
                    tasks: ['copy:src', 'bell']
                }
            }
        }
    );

//load plugins
    grunt.loadNpmTasks('grunt-dot-compiler');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-watch');

//register tasks
    grunt.registerTask('default', ['clean:before', 'copy:src', 'coffee:build', 'dot', 'uglify:build', 'less:build', 'clean:after']);
    grunt.registerTask('debug', ['clean:before', 'copy:src', 'coffee:debug', 'dot', 'uglify:debug', 'less:debug']);
};