module.exports = {
  resolve: {
    extensions: [".js", ".ts", ".json", ".tsx", ".css"]
  },
  entry: "./web/ts/entry.tsx",
  output: {
    // options related how webpack emits results
    path: "./priv/static/", // string
    // the target directory for all output files
    // must be an absolute path (use the Node.js path module)

    filename: "bundle.js", // string
    // the filename template for entry chunks

    publicPath: "/assets/", // string
    // the url to the output directory resolved relative to the HTML page
  },
  module: {
    rules: [{
      test: /\.tsx?$/,
      loader: "ts-loader"
    }]
  }
}
