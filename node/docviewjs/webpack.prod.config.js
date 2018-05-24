
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')

module.exports = {
    entry: "./src/app.ts",
    output: {
        filename: "docview.js"
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
    optimization: {
        minimizer: [
            new UglifyJsPlugin({
                uglifyOptions: {
                    compress: {                
                        drop_console: true
                    }
                }
            })
        ]
    }
}
