
const MinifyPlugin = require("babel-minify-webpack-plugin");

module.exports = {
    entry: "./src/hoverlink.ts",
    output: {
        filename: "hoverlink.js"
    },
    resolve: {
        // Add '.ts' and '.tsx' as a resolvable extension.
        extensions: [".webpack.js", ".web.js", ".ts", ".tsx", ".js"]
    },
    module: {
        rules: [
            // all files with a '.ts' or '.tsx' extension will be handled by 'ts-loader'
            { test: /\.tsx?$/, loader: "ts-loader" }
        ]
    },
    mode: "production",
    plugins: [
        new MinifyPlugin({}, {
            comments: false
        })
    ]
}
