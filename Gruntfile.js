module.exports = function (grunt) {
    var uglifyFiles = [
        {
            'build/js/test.min.js': ['build/js/test.js']
        }
    ];

    grunt.initConfig({
            pkg: grunt.file.readJSON('package.json'),
            coffee: {
                files: {
                    expand: true,
                    flatten: false,
                    cwd: 'src/',
                    src: ['js/*.coffee'],
                    dest: 'build/',
                    ext: '.js'
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
                    tasks: ['copy:src', 'coffee', 'uglify:debug', 'bell']
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
    grunt.registerTask('default', ['clean:before', 'copy:src', 'coffee', 'uglify:build', 'less:build', 'clean:after']);
    grunt.registerTask('debug', ['clean:before', 'copy:src', 'coffee', 'uglify:debug', 'less:debug', 'clean:after', 'watch']);
};