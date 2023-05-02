const { expect } = require("chai");

describe("ScriptyCore Tests", function () {
    async function deploy() {
        const scriptyCore = await (await ethers.getContractFactory("ScriptyCore")).deploy()
        await scriptyCore.deployed()
        return {scriptyCore}
    }

    describe("wrapPrefixAndSuffixFor()", async function () {
        // covered in other tests
    });

    describe("wrapURLSafePrefixAndSuffixFor()", async function () {
        // covered in other tests
    });

    describe("getBufferSizeForHeadTags()", async function () {
        // covered in other tests
    });

    describe("fetchScript()", async function () {
        // covered in other tests
    });

    describe("buildInlineScriptsAndGetSize()", async function () {
        it("Return 0 for empty array", async function () {
            const { scriptyCore } = await deploy()

            const output = await scriptyCore.buildInlineScriptsAndGetSize([]);
            expect(output[1]).to.eq(ethers.BigNumber.from(0));
        });
    });

    describe("buildWrappedScriptsAndGetSize()", async function () {
        it("Return 0 for empty array", async function () {
            const { scriptyCore } = await deploy()

            const output = await scriptyCore.buildWrappedScriptsAndGetSize([]);
            expect(output[1]).to.eq(ethers.BigNumber.from(0));
        });
    });

    describe("buildWrappedURLSafeScriptsAndGetSize()", async function () {
        it("Return 0 for empty array", async function () {
            const { scriptyCore } = await deploy()

            const output = await scriptyCore.buildWrappedURLSafeScriptsAndGetSize([]);
            expect(output[1]).to.eq(ethers.BigNumber.from(0));
        });
    });

    describe("sizeForBase64Encoding()", async function () {
        // covered in other tests
    });
});