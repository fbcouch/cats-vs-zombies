/* global module:false */
module.exports = function(grunt) {
	var port = grunt.option('port') || 8000;
	// Project configuration
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		meta: {
			banner:
				'/*!\n' +
				' * Cats vs Zombies <%= pkg.version %> (<%= grunt.template.today("yyyy-mm-dd, HH:MM") %>)\n' +
				' * https://github.com/fbcouch/cats-vs-zombies\n' +
				' * Apache 2.0 licensed\n' +
				' *\n' +
				' * Copyright (C) 2013 Jami Couch, http://jamicouch.com\n' +
				' */'
		},

		connect: {
			server: {
				options: {
					port: port,
					base: '.'
				}
			}
		},

		watch: {
			main: {
				files: [ 'Gruntfile.js'/*, 'index.html', 'out/*'*/ ],
				tasks: 'default'
			}
		},

        coffee: {
            glob_to_multiple: {
                options: {
                    sourceMap: true
                },
                expand: true,
                flatten: true,
                cwd: 'src',
                src: ['*.coffee'],
                dest: 'out',
                ext: '.js'
            }
        }

	});

	// Dependencies
	grunt.loadNpmTasks( 'grunt-contrib-watch' );
	grunt.loadNpmTasks( 'grunt-contrib-connect' );
    grunt.loadNpmTasks( 'grunt-contrib-coffee' );

	// Default task
	grunt.registerTask( 'default', [ 'connect', 'watch' ] );

};
