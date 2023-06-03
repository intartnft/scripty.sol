const { expect } = require("chai");
const utilities = require("./utilities")

exports.expectHTMLCompare = (name, actual, path, recordMode = false) => {
    if (recordMode) {
        writeHTMLResult(name, actual, path)
        return
    }
    const expected = readExpectedHTMLResult(name, path)
    expect(actual).to.equal(expected)
}

const writeHTMLResult = (name, result, path) => {
    const fileName = name.replace(/\s/g, '');
    utilities.writeFile(path + fileName + ".html", result)
}

const readExpectedHTMLResult = (name, path) => {
    const fileName = name.replace(/\s/g, '');
    const data = utilities.readFile(path + fileName + ".html")
    return data;
}

exports.addHeadRequest = (headRequests) => {
    for (let i = 0; i < 1; i++) {
        headRequests.push([
            utilities.stringToBytes("<title>"),
            utilities.stringToBytes("</title>"),
            utilities.stringToBytes("Hello World")
        ])
    }
    return headRequests
}

exports.getHtmlRequest = (headRequests, scriptRequests) => {
    return [
        headRequests,
        scriptRequests
    ]
}