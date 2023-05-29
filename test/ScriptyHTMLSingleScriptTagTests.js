const { expect } = require("chai");
const utilities = require("../utilities/utilities")

const recordMode = false;
const expectedResultsPath = __dirname + "/expectedResults/ScriptyHTMLSingleScriptTag/";

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

describe("getHTMLSingleScriptTag Tests", function () {
    async function deploy() {
        const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
        await contentStore.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
            contentStore.address
        )
        await scriptyStorageContract.deployed()

        const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyHTMLSingleScriptTag")).deploy()
        await scriptyBuilderContract.deployed()

        return { scriptyStorageContract, scriptyBuilderContract }
    }

    async function addContractScripts(scriptRequests, scriptyStorageContract) {
        const baseScript = "inlineScript"

        for (let i = 0; i < 2; i++) {
            const scriptId = scriptRequests.length;
            const scriptName = baseScript + scriptId
            await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
            await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(baseScript + i))
            scriptRequests.push([scriptName, scriptyStorageContract.address, 0, 0, 0, 0, utilities.emptyBytes()])
        }

        return scriptRequests
    }

    function addScriptsWithContent(scriptRequests) {
        const baseScriptContent = "scriptContent"
        for (let i = 0; i < 2; i++) {
            scriptRequests.push(["", utilities.emptyAddress, 0, 0, 0, 0, utilities.stringToBytes(baseScriptContent + i)])
        }
        return scriptRequests
    }

    function addHeadRequest(headRequests) {
        for (let i=0; i< 2; i++) {
            headRequests.push([
                utilities.stringToBytes("<title>"),
                utilities.stringToBytes("</title>"),
                utilities.stringToBytes("Hello World")
            ])
        }
        return headRequests
    }
    
    function getHtmlRequest(headRequests, scriptRequests) {
        return [
            headRequests,
            scriptRequests
        ]
    }

    async function assertHTML(title, contract, headRequests, scriptRequests, isEncoded = false) {
        const htmlRequest = getHtmlRequest(headRequests, scriptRequests)

        const htmlRaw = await contract.getHTMLSingleScriptTag(htmlRequest)
        const htmlRawString = utilities.bytesToString(htmlRaw)

        const htmlEncoded = await contract.getEncodedHTMLSingleScriptTag(htmlRequest)
        const htmlEncodedString = utilities.bytesToString(htmlEncoded)

        expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlEncodedString))
        expectHTML(title + "_encoded", htmlEncodedString);
        expectHTML(title, htmlRawString);
    }

    describe("HTML with single script tag tests", async function () {
        it("Without headers", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let scriptRequests = []
            await addContractScripts(scriptRequests, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, [], scriptRequests);
        });
        
        it("Only contract scripts", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Only scripts with content", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(scriptRequests, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, scriptyStorageContract)
            await addScriptsWithContent(scriptRequests)
            await addContractScripts(scriptRequests, scriptyStorageContract)
            await addScriptsWithContent(scriptRequests)

            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });
    })
});
