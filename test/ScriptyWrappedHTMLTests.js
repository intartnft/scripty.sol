const { expect } = require("chai");
const utilities = require("../utilities/utilities")

const recordMode = true;
const expectedResultsPath = __dirname + "/expectedResults/ScriptyWrappedHTML/";

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

describe("ScriptyWrappedHTML Tests", function () {
    async function deploy() {
        const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
        await contentStore.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
            contentStore.address
        )
        await scriptyStorageContract.deployed()

        const scriptyWrappedHTMLContract = await (await ethers.getContractFactory("ScriptyWrappedHTML")).deploy()
        await scriptyWrappedHTMLContract.deployed()

        return { scriptyStorageContract, scriptyWrappedHTMLContract }
    }

    async function addContractScripts(scriptRequests, wrapType, scriptyStorageContract) {
        const baseScript = "wrappedScript"

        let wrapPrefix = utilities.emptyBytes()
        let wrapSuffix = utilities.emptyBytes()

        if (wrapType == 4) {
            wrapPrefix = utilities.stringToBytes("<wrapPrefix>")
            wrapSuffix = utilities.stringToBytes("</wrapSuffix>")
        }

        for (let i = 0; i < 2; i++) {
            const scriptId = scriptRequests.length;
            const scriptName = baseScript + scriptId
            await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
            await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(baseScript + i))
            scriptRequests.push([scriptName, scriptyStorageContract.address, 0, wrapType, wrapPrefix, wrapSuffix, utilities.emptyBytes()])
        }

        return scriptRequests
    }

    function addScriptsWithContent(wrapType, scriptRequests) {
        const baseScriptContent = "scriptContent"

        let wrapPrefix = utilities.emptyBytes()
        let wrapSuffix = utilities.emptyBytes()

        if (wrapType == 4) {
            wrapPrefix = utilities.stringToBytes("<wrapPrefix>")
            wrapSuffix = utilities.stringToBytes("</wrapSuffix>")
        }

        for (let i = 0; i < 2; i++) {
            scriptRequests.push(["", utilities.emptyAddress, 0, wrapType, wrapPrefix, wrapSuffix, utilities.stringToBytes(baseScriptContent + i)])
        }
        return scriptRequests
    }

    function addHeadRequest(headRequests) {
        for (let i = 0; i < 2; i++) {
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

    async function assertHTML(title, contract, headRequests, scriptRequests) {
        const htmlRequest = getHtmlRequest(headRequests, scriptRequests)

        const htmlRaw = await contract.getHTMLWrapped(htmlRequest)
        const htmlRawString = utilities.bytesToString(htmlRaw)

        const htmlEncoded = await contract.getEncodedHTMLWrapped(htmlRequest)
        const htmlEncodedString = utilities.bytesToString(htmlEncoded)

        expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlEncodedString))
        expectHTML(title + "_encoded", htmlEncodedString);
        expectHTML(title, htmlRawString);
    }

    describe("Wrapped HTML Tests - Only contract scripts", async function () {
        it("Only contract scripts - wrapType = 0", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 0, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - wrapType = 1", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 1, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - wrapType = 2", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 2, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - wrapType = 3", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 3, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - wrapType = 4", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 4, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });
    })

    describe("Wrapped HTML Tests - Scripts with content", async function () {
        it("Scripts with content - wrapType = 0", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(0, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Scripts with content - wrapType = 1", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(1, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Scripts with content - wrapType = 2", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(2, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Scripts with content - wrapType = 3", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(3, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Scripts with content - wrapType = 4", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(4, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });
    })

    describe("Wrapped HTML Tests - Contract scripts + scripts with content", async function () {
        it("Contract scripts + scripts with content - wrapType = 0", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 0, scriptyStorageContract)
            await addScriptsWithContent(0, scriptRequests)
            await addContractScripts(scriptRequests, 0, scriptyStorageContract)
            await addScriptsWithContent(0, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - wrapType = 1", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 1, scriptyStorageContract)
            await addScriptsWithContent(1, scriptRequests)
            await addContractScripts(scriptRequests, 1, scriptyStorageContract)
            await addScriptsWithContent(1, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - wrapType = 2", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 2, scriptyStorageContract)
            await addScriptsWithContent(2, scriptRequests)
            await addContractScripts(scriptRequests, 2, scriptyStorageContract)
            await addScriptsWithContent(2, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - wrapType = 3", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 3, scriptyStorageContract)
            await addScriptsWithContent(3, scriptRequests)
            await addContractScripts(scriptRequests, 3, scriptyStorageContract)
            await addScriptsWithContent(3, scriptRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - wrapType = 4", async function () {
            const { scriptyStorageContract, scriptyWrappedHTMLContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 4, scriptyStorageContract)
            await addScriptsWithContent(4, scriptRequests)
            await addContractScripts(scriptRequests, 4, scriptyStorageContract)
            await addScriptsWithContent(4, scriptRequests)

            await assertHTML(this.test.fullTitle(), scriptyWrappedHTMLContract, headRequests, scriptRequests);
        });
    })
});
