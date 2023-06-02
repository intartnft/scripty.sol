const { expect } = require("chai");
const utilities = require("../utilities/utilities")

const recordMode = false;
const expectedResultsPath = __dirname + "/expectedResults/ScriptyHTMLURLSafe/";

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

describe("ScriptyHTMLURLSafe Tests", function () {
    async function deploy() {
        const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
        await contentStore.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
            contentStore.address
        )
        await scriptyStorageContract.deployed()

        const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyHTMLURLSafe")).deploy()
        await scriptyBuilderContract.deployed()

        return { scriptyStorageContract, scriptyBuilderContract }
    }

    async function addContractScripts(scriptRequests, tagType, scriptyStorageContract) {
        const baseScript = "wrappedScript"

        let tagOpen = utilities.emptyBytes()
        let tagClose = utilities.emptyBytes()

        if (tagType == 4) {
            tagOpen = utilities.stringToBytes("<script>")
            tagClose = utilities.stringToBytes("</script>")
        }

        for (let i = 0; i < 2; i++) {
            const scriptId = scriptRequests.length;
            const scriptName = baseScript + scriptId
            await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
            await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(baseScript + i))
            scriptRequests.push([scriptName, scriptyStorageContract.address, 0, tagType, tagOpen, tagClose, utilities.emptyBytes()])
        }

        return scriptRequests
    }

    function addScriptsWithContent(tagType, scriptRequests) {
        const baseScriptContent = "scriptContent"

        let tagOpen = utilities.emptyBytes()
        let tagClose = utilities.emptyBytes()

        if (tagType == 4) {
            tagOpen = utilities.stringToBytes("<script>")
            tagClose = utilities.stringToBytes("</script>")
        }

        for (let i = 0; i < 2; i++) {
            scriptRequests.push(["", utilities.emptyAddress, 0, tagType, tagOpen, tagClose, utilities.stringToBytes(baseScriptContent + i)])
        }
        return scriptRequests
    }

    function addHeadRequest(headRequests) {
        for (let i = 0; i < 2; i++) {
            headRequests.push([
                utilities.stringToBytes("%3Ctitle%3E"),
                utilities.stringToBytes("%3C%2Ftitle%3E"),
                utilities.stringToBytes("Hello%20World")
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

        const htmlRaw = await contract.getHTMLURLSafe(htmlRequest)
        const htmlRawString = utilities.bytesToString(htmlRaw)

        expectHTML(title, htmlRawString);
    }

    describe("Get URL Safe HTML Tests - Zero requests", async function () {
        it("Zero scripts amd Zero head", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });
    });

    describe("Get HTML String", async function () {
        it("Zero scripts amd Zero head", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            const htmlRequest = getHtmlRequest(headRequests, scriptRequests)

            const htmlRaw = await scriptyBuilderContract.getHTMLURLSafe(htmlRequest)
            const htmlRawString = utilities.bytesToString(htmlRaw)
            const htmlString = await scriptyBuilderContract.getHTMLURLSafeString(htmlRequest);

            expect(htmlRawString).to.eq(htmlString);
        });
    });

    describe("Get URL Safe HTML Tests - Only contract scripts", async function () {
        it("Only contract scripts - tagType = 0", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 0, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - tagType = 1", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 1, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - tagType = 2", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 2, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - tagType = 3", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 3, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Only contract scripts - tagType = 4", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 4, scriptyStorageContract)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });
    })

    describe("Get URL Safe HTML Tests - Scripts with content", async function () {
        it("Scripts with content - tagType = 0", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(0, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Scripts with content - tagType = 1", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(1, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Scripts with content - tagType = 2", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(2, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Scripts with content - tagType = 3", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(3, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Scripts with content - tagType = 4", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addScriptsWithContent(4, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });
    })

    describe("Get URL Safe HTML Tests - Contract scripts + scripts with content", async function () {
        it("Contract scripts + scripts with content - tagType = 0", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 0, scriptyStorageContract)
            await addScriptsWithContent(0, scriptRequests)
            await addContractScripts(scriptRequests, 0, scriptyStorageContract)
            await addScriptsWithContent(0, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - tagType = 1", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 1, scriptyStorageContract)
            await addScriptsWithContent(1, scriptRequests)
            await addContractScripts(scriptRequests, 1, scriptyStorageContract)
            await addScriptsWithContent(1, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - tagType = 2", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 2, scriptyStorageContract)
            await addScriptsWithContent(2, scriptRequests)
            await addContractScripts(scriptRequests, 2, scriptyStorageContract)
            await addScriptsWithContent(2, scriptRequests)
            addHeadRequest(headRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - tagType = 3", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 3, scriptyStorageContract)
            await addScriptsWithContent(3, scriptRequests)
            await addContractScripts(scriptRequests, 3, scriptyStorageContract)
            await addScriptsWithContent(3, scriptRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });

        it("Contract scripts + scripts with content - tagType = 4", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headRequests = []
            let scriptRequests = []

            await addContractScripts(scriptRequests, 4, scriptyStorageContract)
            await addScriptsWithContent(4, scriptRequests)
            await addContractScripts(scriptRequests, 4, scriptyStorageContract)
            await addScriptsWithContent(4, scriptRequests)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headRequests, scriptRequests);
        });
    })
});
