module.exports = function(config) {
  config.set({
    basePath: '',

    frameworks: ['phantomjs-shim', 'jasmine'],

    files: [
      'specs/main.js'
    ],

    exclude: [
    ],

    preprocessors: {
      'specs/main.js': ['rollup']
    },

    rollupPreprocessor: {
      rollup: {
        plugins: [
          require('rollup-plugin-babel')({
            presets: [
              require('babel-preset-es2015-rollup'),
              require('babel-preset-stage-1'),
              require('babel-preset-react'),
            ]
          }),
          require('rollup-plugin-node-resolve')({
            // use "jsnext:main" if possible
            // – see https://github.com/rollup/rollup/wiki/jsnext:main
            jsnext: true,

            // use "main" field or index.js, even if it's not an ES6 module
            // (needs to be converted from CommonJS to ES6
            // – see https://github.com/rollup/rollup-plugin-commonjs
            main: true
          }),
          require('rollup-plugin-commonjs')()
        ],
      },
      bundle: {
        format: 'iife',
        sourceMap: 'inline'
      }
    },

    reporters: ['progress'],

    port: 9876,

    colors: true,

    logLevel: config.LOG_INFO,

    autoWatch: false,

    browsers: ['PhantomJS', 'Firefox', process.env.TRAVIS ? 'Chrome_travis_ci' : 'Chrome'],

    customLaunchers: {
      Chrome_travis_ci: {
        base: 'Chrome',
        flags: ['--no-sandbox']
      }
    },

    singleRun: false,

    plugins: [
      require('karma-jasmine'),
      require('karma-phantomjs-launcher'),
      require('karma-firefox-launcher'),
      require('karma-chrome-launcher'),
      require('karma-rollup-preprocessor'),
      require('karma-phantomjs-shim')
    ]
  });
};
