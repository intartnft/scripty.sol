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

let storageIndex = 0;
exports.addContractTag = async (tags, tagType, isURLSafe, scriptyStorageContract) => {
    const tagContent = "tagContentFromStorage"

    let tagOpen = utilities.emptyBytes()
    let tagClose = utilities.emptyBytes()

    if (tagType == 0) {
        if (isURLSafe) {
            tagOpen = utilities.stringToBytes(utilities.toURLSafeDouble("<tagOpen>"))
        }else{
            tagOpen = utilities.stringToBytes("<tagOpen>")
        }
        if (isURLSafe) {
            tagClose = utilities.stringToBytes(utilities.toURLSafeDouble("<tagClose>"))
        }else{
            tagClose = utilities.stringToBytes("</tagClose>")
        }
    }

    for (let i = 0; i < 2; i++) {
        const name = tagContent + storageIndex
        await scriptyStorageContract.addChunkToContent(name, utilities.stringToBytes(tagContent + i))
        tags.push([name, scriptyStorageContract.address, 0, tagType, tagOpen, tagClose, utilities.emptyBytes()])
        storageIndex++
    }

    return tags
}

exports.addTagWithContent = (tags, tagType, isURLSafe) => {
    const tagContent = "tagContent"

    let tagOpen = utilities.emptyBytes()
    let tagClose = utilities.emptyBytes()

    if (tagType == 0) {
        if (isURLSafe) {
            tagOpen = utilities.stringToBytes(utilities.toURLSafeDouble("<tagOpen>"))
        }else{
            tagOpen = utilities.stringToBytes("<tagOpen>")
        }
        if (isURLSafe) {
            tagClose = utilities.stringToBytes(utilities.toURLSafeDouble("<tagClose>"))
        }else{
            tagClose = utilities.stringToBytes("</tagClose>")
        }
    }

    for (let i = 0; i < 2; i++) {
        tags.push(["", utilities.emptyAddress, 0, tagType, tagOpen, tagClose, utilities.stringToBytes(tagContent + i)])
    }
    return tags
}

exports.createNonContractHTMLTag = (tagOpen, tagContent, tagClose, tagType) => {
    let tagOpenBytes = utilities.stringToBytes(tagOpen)
    let tagCloseBytes = utilities.stringToBytes(tagClose)
    let tagContentBytes = utilities.stringToBytes(tagContent)
    return ["", utilities.emptyAddress, 0, tagType, tagOpenBytes, tagCloseBytes, tagContentBytes]
}

exports.getHtmlRequest = (headRequests, scriptRequests) => {
    return [
        headRequests,
        scriptRequests
    ]
}