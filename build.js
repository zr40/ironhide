({
	appDir: 'build/work',
	baseUrl: '.',
	dir: 'build/minified',

	name: 'almond',
	include: ['cs!main'],
	stubModules: ['cs'],
	excludeShallow: [
		'coffee-script',
	],

	paths: {
		'coffee-script': 'lib/coffee-script',
		'socket.io': '../../node_modules/socket.io/lib/socket.io',
		almond: 'lib/almond',
		backbone: 'lib/backbone',
		cs: 'lib/cs',
		Handlebars: 'lib/handlebars',
		hbs: 'lib/hbs',
		i18nprecompile: 'lib/i18nprecompile',
		jquery: 'lib/jquery',
		json2: 'lib/json2',
		underscore: 'lib/underscore',
	},

	useStrict: true,

	optimize: 'uglify2',
	preserveLicenseComments: false,
	generateSourceMaps: true,
	uglify2: {
		output: {
			ie_proof: false,
			space_colon: false,
		},
		compress: {
			unsafe: true,
		},
		warnings: true,
	},
	hbs: {
		disableI18n: true,
	},

	optimizeCss: 'standard',
})
