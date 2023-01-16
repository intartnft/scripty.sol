
const fs = require('fs');
const Terser = require("Terser");
const path = require('path');

const utilities = require("../utilities/utilities")

const buildPath = "/dist"
const srcPath = "/src"

const minifyJS = async (code) => {
    return (await Terser.minify(code, {
        mangle: true,
        ecma: 8,
        compress: false
    })).code;
}

async function main() {
    fs.readdirSync(path.join(__dirname, srcPath)).forEach(async file => {
        const srcCode = utilities.readFile(path.join(__dirname, srcPath, file))
        const minifiedCodeResult = await minifyJS(srcCode)
        utilities.writeFile(path.join(__dirname, buildPath, file), minifiedCodeResult)
    });
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});