import babel from 'rollup-plugin-babel';
import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
  entry: 'index.es6',
  dest: 'dist/react-draggable.js',
  sourceMap: 'dist/react-draggable.js.map',
  moduleName: 'ReactDraggable',
  external: ['react', 'react-dom'],
  plugins: [
    babel(),
    nodeResolve({
      // use "jsnext:main" if possible
      // – see https://github.com/rollup/rollup/wiki/jsnext:main
      jsnext: true,

      // use "main" field or index.js, even if it's not an ES6 module
      // (needs to be converted from CommonJS to ES6
      // – see https://github.com/rollup/rollup-plugin-commonjs
      main: true
    }),
    commonjs()
  ],
  format: 'umd'
};
