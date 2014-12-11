module.exports = function (grunt) {
    var uglifyFiles = [
        {
            'build/js/graphalizer.min.js': ['build/js/graphalizer.js']
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
                        'build/js/graphalizer.js': ['src/js/*.coffee']
                    }
                },
                debug: {
                    options: {
                        sourceMap: true,
                        join: true
                    },
                    files: {
                        'build/js/graphalizer.min.js': ['src/js/*.coffee']
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
            clean: {
                before: [
                    'build'
                ],
                after: [
                    'build/js/*.js',
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
                    files: 'src/js/*.coffee',
                    tasks: ['coffee:debug', 'bell']
                },
                anything: {
                    files: ['src/**/*', '!**/*.less', '!**/*.coffee'],
                    tasks: ['copy:src', 'bell']
                }
            }
        }
    );

//load plugins
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-bell');

//register tasks
    grunt.registerTask('default', ['clean:before', 'copy:src', 'coffee:build', 'uglify:build', 'less:build', 'clean:after']);
    grunt.registerTask('debug', ['clean:before', 'copy:src', 'coffee:debug', 'less:debug']);
};