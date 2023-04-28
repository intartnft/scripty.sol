const { expect } = require("chai");
const utilities = require("../utilities/utilities")

const recordMode = true;
const expectedResultsPath = __dirname + "/expectedResults/ScriptyInlineHTML/";

const writeHTMLResult = (name, result) => {
    const fileName = name.replace(/\s/g, '');
    utilities.writeFile(expectedResultsPath + fileName + ".html", result)
}

const readExpectedHTMLResult = (name) => {
    const fileName = name.replace(/\s/g, '');
    const data = utilities.readFile(expectedResultsPath + fileName + ".html")
    return data;
}

const expectHTML = (name, actual) => {
    if (recordMode) {
        writeHTMLResult(name, actual)
        return
    }
    const expected = readExpectedHTMLResult(name)
    expect(actual).to.equal(expected)
}

describe.only("ScriptyInlineHTML Tests", function () {
    const controllerScript = "controllerScript"

    async function deploy() {
        const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
        await contentStore.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
            contentStore.address
        )
        await scriptyStorageContract.deployed()

        const scriptyInlineHTMLContract = await (await ethers.getContractFactory("ScriptyInlineHTML")).deploy()
        await scriptyInlineHTMLContract.deployed()

        return { scriptyStorageContract, scriptyInlineHTMLContract }
    }

    async function addInlineScripts(scriptyStorageContract, scriptContent = utilities.emptyBytes()) {
        const script = "inlineScript"
        let scriptRequests = []

        for (let i = 0; i < 2; i++) {
            let scriptName = "script" + i
            await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
            await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(script + i))
            scriptRequests.push([scriptName, scriptyStorageContract.address, 0, scriptContent])
        }

        return { scriptRequests }
    }


    function createControllerScriptRequestInline() {
        return ["", utilities.emptyAddress, 0, utilities.stringToBytes(controllerScript)]
    }

    async function addHeadTag() {
        return [
            utilities.stringToBytes("<title>"),
            utilities.stringToBytes("</title>"),
            utilities.stringToBytes("Hello World")
        ]
    }

    async function callWithSizeCheck(title, contract, headTags, requests, isEncoded = false) {
        const scriptSize = await contract.getBufferSizeForHTMLInline(headTags, requests)
        const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

        const htmlRaw = await contract.getHTMLInline(headTags, requests, scriptSize)
        const htmlRawString = utilities.bytesToString(htmlRaw)

        if (isEncoded) {
            console.log('test 1', scriptSize);
            const htmlEncoded = await contract.getEncodedHTMLInline(headTags, requests, scriptSize)
            console.log('test 2');
            const htmlEncodedString = utilities.bytesToString(htmlEncoded)

            expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlEncodedString))
            console.log('test 3');
            expectHTML(title, htmlEncodedString);
            console.log('test 4');

            await expect(contract.getHTMLInline(headTags, requests, invalidSize))
                .to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
        } else {
            expectHTML(title, htmlRawString);

            await expect(contract.getHTMLInline(headTags, requests, invalidSize))
                .to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
        }
    }

    describe("Store Script and get raw HTML", async function () {

        async function wrapTypeTest(title) {
            const { scriptyStorageContract, scriptyInlineHTMLContract } = await deploy()
            const { scriptRequests } = await addInlineScripts(scriptyStorageContract)

            const headTags = [await addHeadTag()];
            await callWithSizeCheck(title, scriptyInlineHTMLContract, headTags, scriptRequests);
        }

        it("Store Script and get HTML - Inline", async function () {
            await wrapTypeTest(this.test.fullTitle())
        });
    })

    describe("Store Script and get raw HTML with controller script", async function () {

        async function controllerScriptTest(title, splice = false, start = 0, deleteCount = 0) {
            const { scriptyStorageContract, scriptyInlineHTMLContract } = await deploy()
            let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

            if (splice) {
                scriptRequests.splice(start, deleteCount,
                    createControllerScriptRequestInline()
                );
            } else {
                scriptRequests.push(
                    createControllerScriptRequestInline()
                );
            }

            const headTags = [await addHeadTag()];
            await callWithSizeCheck(title, scriptyInlineHTMLContract, headTags, scriptRequests, false);
        }

        it("Store Script and get HTML - Inline - Controller Script at beginning", async function () {
            await controllerScriptTest(this.test.fullTitle(), true, 0, 0)
        });

        it("Store Script and get HTML - Inline - Controller Script in middle", async function () {
            await controllerScriptTest(this.test.fullTitle(), true, 1, 0)
        });

        it("Store Script and get HTML - Inline - Controller Script at the end", async function () {
            await controllerScriptTest(this.test.fullTitle())
        });
    })

    describe("Store Script and get encoded HTML", async function () {
        it("Store Script and get Encoded HTML - Inline", async function () {
            const { scriptyStorageContract, scriptyInlineHTMLContract } = await deploy()
            const { scriptRequests } = await addInlineScripts(scriptyStorageContract)

            const headTags = [await addHeadTag()];
            await callWithSizeCheck(this.test.fullTitle(), scriptyInlineHTMLContract, headTags, scriptRequests, true);
        });
    })

    describe("Store Script and get Encoded HTML with controller script", async function () {

        async function controllerScriptWithEncodingTest(title, splice = false, start = 0, deleteCount = 0) {
            const { scriptyStorageContract, scriptyInlineHTMLContract } = await deploy()
            let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

            if (splice) {
                scriptRequests.splice(start, deleteCount,
                    createControllerScriptRequestInline()
                );
            } else {
                scriptRequests.push(
                    createControllerScriptRequestInline()
                );
            }

            const headTags = [await addHeadTag()];
            await callWithSizeCheck(title, scriptyInlineHTMLContract, headTags, scriptRequests, true);
        }

        it("Store Script and get Encoded HTML - Inline - Controller Script at beginning", async function () {
            await controllerScriptWithEncodingTest(this.test.fullTitle(), true, 0, 0)
        });

        it("Store Script and get Encoded HTML - Inline - Controller Script in middle", async function () {
            await controllerScriptWithEncodingTest(this.test.fullTitle(), true, 1, 0)
        });

        it("Store Script and get Encoded HTML - Inline - Controller Script at the end", async function () {
            await controllerScriptWithEncodingTest(this.test.fullTitle())
        });
    })
});
