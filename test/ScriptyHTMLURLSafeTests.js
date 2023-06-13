const { expect } = require("chai");
const utilities = require("../utilities/utilities")
const testUtilities = require("../utilities/testUtils")

const expectedResultsPath = __dirname + "/expectedResults/ScriptyHTMLURLSafe/";

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

    async function assertHTML(title, contract, headRequests, scriptRequests) {
        const htmlRequest = testUtilities.getHtmlRequest(headRequests, scriptRequests)

        const htmlRaw = await contract.getHTMLURLSafe(htmlRequest)
        const htmlRawString = utilities.bytesToString(htmlRaw)
        const htmlDecodedString = utilities.parseDoubleURLEncodedDataURI(htmlRawString)
        
        testUtilities.expectHTMLCompare(title + "_decoded", htmlDecodedString, expectedResultsPath)
        testUtilities.expectHTMLCompare(title, htmlRawString, expectedResultsPath)
    }

    describe("Get URL Safe HTML Tests - Zero tags", async function () {
        it("Zero head and body tags", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    });

    describe("Get HTML String", async function () {
        it("Zero head and body tags", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            const htmlRequest = testUtilities.getHtmlRequest(headTags, bodyTags)

            const htmlRaw = await scriptyBuilderContract.getHTMLURLSafe(htmlRequest)
            const htmlRawString = utilities.bytesToString(htmlRaw)
            const htmlString = await scriptyBuilderContract.getHTMLURLSafeString(htmlRequest);

            expect(htmlRawString).to.eq(htmlString);
        });
    });

    describe("Get URL Safe HTML Tests - Only contract tags", async function () {
        it("Only contract tags - body tagType = script", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)
            await testUtilities.addContractTag(bodyTags, 1, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = scriptBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)
            await testUtilities.addContractTag(bodyTags, 2, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = scriptGZIPBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)
            await testUtilities.addContractTag(bodyTags, 3, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = scriptPNGBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)
            await testUtilities.addContractTag(bodyTags, 4, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)
            await testUtilities.addContractTag(bodyTags, 0, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    })

    describe("Get URL Safe HTML Tests - Tags with content", async function () {
        it("Tags with content - body tagType = script", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 1, true)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = scriptBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 2, true)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = scriptGZIPBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 3, true)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = scriptPNGBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 4, true)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 0, true)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    })

    describe("Get URL Safe HTML Tests - Contract scripts + scripts with content", async function () {
        it("Contract tags + tags with content - body tagType = script", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, true)
            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 1, true)
            await testUtilities.addContractTag(bodyTags, 1, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, true)
            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 2, true)
            await testUtilities.addContractTag(bodyTags, 2, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptGZIPBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, true)
            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 3, true)
            await testUtilities.addContractTag(bodyTags, 3, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        iit("Contract tags + tags with content - body tagType = scriptPNGBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, true)
            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 4, true)
            await testUtilities.addContractTag(bodyTags, 4, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, true)
            await testUtilities.addContractTag(headTags, 0, true, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 0, true)
            await testUtilities.addContractTag(bodyTags, 0, true, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    })
});
