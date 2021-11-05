const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = (env, argv) => {
  return {
    entry: ["@babel/polyfill", path.join(__dirname, "src")],
    stats: "minimal",
    output: {
      path: path.join(
        __dirname,
        argv.mode === "development" ? "playground/dapp" : "prod/dapp"
      ),
      filename: "[name].[hash].js",
      publicPath: "/playground/",
    },
    module: {
      rules: [
        {
          test: /\.(js|jsx)$/,
          use: "babel-loader",
          exclude: /node_modules/,
        },
        {
          test: /\.css$/,
          use: [
            "style-loader",
            "css-loader",
            {
              loader: "postcss-loader",
              options: {
                config: {
                  path: "./postcss.config.js",
                },
              },
            },
          ],
        },
        {
          test: /\.(png|svg|jpg|gif)$/,
          use: [
            {
              loader: "file-loader",
              options: {
                name: "assets/[name].[ext]?[hash]",
              },
            },
          ],
        },
        {
          test: /\.(woff(2)?|ttf|eot)(\?v=\d+\.\d+\.\d+)?$/,
          use: [
            {
              loader: "file-loader",
              options: {
                name: "assets/fonts/[name].[ext]",
              },
            },
          ],
        },
        {
          test: /\.html$/,
          use: "html-loader",
          exclude: /node_modules/,
        },
      ],
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: path.join(__dirname, "src/index.html"),
      }),
      // new MiniCssExtractPlugin()
    ],
    resolve: {
      extensions: [".js", ".jsx"],
    },
    devtool: "source-map",
    devServer: {
      port: 5001,
      host: "0.0.0.0",
      allowedHosts: "all",
      static: true,
      historyApiFallback: {
        index: "/playground/",
      },
      open: false,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    },
  };
};
