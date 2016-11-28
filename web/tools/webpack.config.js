module.exports = {
  entry: "./web/ts/entry.tsx",
  output: {
    path: "./priv/static/js",
    filename: "app.js"
  },
  resolve: {
    // Add `.ts` and `.tsx` as a resolvable extension.
    extensions: ['', '.webpack.js', '.web.js', '.ts', '.tsx', '.js']
  },
  module: {
    loaders: [
      { test: /\.tsx?$/, loader: 'ts-loader' },
      { test: /\.scss$/, loader: 'style-loader!css-loader!sass-loader' }
    ]
  }
};
