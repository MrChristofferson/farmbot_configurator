var HtmlWebpackPlugin = require( 'html-webpack-plugin' );

console.log("Welcome to webpack in Elixir Land without Phoenix???!!!");
env = process.env.NODE_ENV;
console.log(env);
module.exports = {
  entry: "./web/js/entry.js",
  output: {
    path: "./priv/static/",
    filename: "bundle.js"
  },
  resolve: {
    modulesDirectories: ['node_modules'],
    extensions:         ['', '.js', '.elm']
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './web/html/index.html',
      inject:   'body',
      filename: 'index.html'
    })
  ],
  module: {
    loaders: [
      { test: /\.css$/, loader: "style-loader!css-loader" },
      { test: /\.elm$/, exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack?verbose=true&warn=true&debug=true'}
    ]
  }
};
