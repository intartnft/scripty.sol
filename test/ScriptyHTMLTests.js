const { expect } = require("chai");
const utilities = require("../utilities/utilities")
const testUtilities = require("../utilities/testUtils")

const expectedResultsPath = __dirname + "/expectedResults/ScriptyHTML/";

describe("ScriptyHTML Tests", function () {
    async function deploy() {
        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyMockStorage")).deploy()
        await scriptyStorageContract.deployed()

        const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyHTML")).deploy()
        await scriptyBuilderContract.deployed()

        return { scriptyStorageContract, scriptyBuilderContract }
    }

    async function assertHTML(title, contract, headTags, bodyTags, recordMode = false) {
        const htmlRequest = testUtilities.getHtmlRequest(headTags, bodyTags)

        const htmlRaw = await contract.getHTML(htmlRequest)
        const htmlRawString = utilities.bytesToString(htmlRaw)

        const htmlEncoded = await contract.getEncodedHTML(htmlRequest)
        const htmlEncodedString = utilities.bytesToString(htmlEncoded)

        expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlEncodedString))
        testUtilities.expectHTMLCompare(title + "_encoded", htmlEncodedString, expectedResultsPath, recordMode)
        testUtilities.expectHTMLCompare(title, htmlRawString, expectedResultsPath, recordMode)
    }

    describe("Get HTML Tests - Zero tags", async function () {
        it("Zero head and body tags", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
            console.log(scriptyBuilderContract.address);

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

            const htmlRaw = await scriptyBuilderContract.getHTML(htmlRequest)
            const htmlRawString = utilities.bytesToString(htmlRaw)
            const htmlString = await scriptyBuilderContract.getHTMLString(htmlRequest);

            expect(htmlRawString).to.eq(htmlString);
        });

        it("Zero head and body tags - encoded", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            const htmlRequest = testUtilities.getHtmlRequest(headTags, bodyTags)

            const htmlRawEncoded = await scriptyBuilderContract.getEncodedHTML(htmlRequest)
            const htmlRawEncodedString = utilities.bytesToString(htmlRawEncoded)
            const htmlEncodedString = await scriptyBuilderContract.getEncodedHTMLString(htmlRequest);

            expect(htmlRawEncodedString).to.eq(htmlEncodedString);
        });
    });

    describe("Get HTML Tests - Only contract scripts", async function () {
        it("Only contract tags - body tagType = script", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(bodyTags, 1, false, scriptyStorageContract)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)
 
            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = scriptBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(bodyTags, 2, false, scriptyStorageContract)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = scriptGZIPBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(bodyTags, 3, false, scriptyStorageContract)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = scriptPNGBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(bodyTags, 4, false, scriptyStorageContract)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Only contract tags - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            await testUtilities.addContractTag(bodyTags, 0, false, scriptyStorageContract)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    })

    describe("Get HTML Tests - Tags with content", async function () {
        it("Tags with content - body tagType = script", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 1, false)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = scriptBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 2, false)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = scriptGZIPBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 3, false)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = scriptPNGBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 4, false)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with content - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            testUtilities.addTagWithContent(bodyTags, 0, false)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Tags with empty content - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = [testUtilities.createNonContractHTMLTag("tagOpen", "", "tagClose", 0)]
            let bodyTags = [testUtilities.createNonContractHTMLTag("tagOpen", "", "tagClose", 0)]

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    })

    describe("Get HTML Tests - Contract tags + Tags with content", async function () {
        it("Contract tags + tags with content - body tagType = script", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 1, false)
            await testUtilities.addContractTag(bodyTags, 1, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 2, false)
            await testUtilities.addContractTag(bodyTags, 2, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptGZIPBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 3, false)
            await testUtilities.addContractTag(bodyTags, 3, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptPNGBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 4, false)
            await testUtilities.addContractTag(bodyTags, 4, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 0, false)
            await testUtilities.addContractTag(bodyTags, 0, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    })

    describe("Get HTML Tests - Contract tags + Tags with content", async function () {
        it("Contract tags + tags with content - body tagType = script", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 1, false)
            await testUtilities.addContractTag(bodyTags, 1, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 2, false)
            await testUtilities.addContractTag(bodyTags, 2, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptGZIPBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 3, false)
            await testUtilities.addContractTag(bodyTags, 3, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = scriptPNGBase64DataURI", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 4, false)
            await testUtilities.addContractTag(bodyTags, 4, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });

        it("Contract tags + tags with content - body tagType = useTagOpenAndClose", async function () {
            const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

            let headTags = []
            let bodyTags = []

            testUtilities.addTagWithContent(headTags, 0, false)
            await testUtilities.addContractTag(headTags, 0, false, scriptyStorageContract)

            testUtilities.addTagWithContent(bodyTags, 0, false)
            await testUtilities.addContractTag(bodyTags, 0, false, scriptyStorageContract)

            await assertHTML(this.test.fullTitle(), scriptyBuilderContract, headTags, bodyTags);
        });
    })
});
