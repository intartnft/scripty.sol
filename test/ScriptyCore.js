const { expect } = require("chai");

describe("ScriptyCore Tests", function () {
    async function deploy() {
        const scriptyCore = await (await ethers.getContractFactory("ScriptyCore")).deploy()
        await scriptyCore.deployed()
        return {scriptyCore}
    }

    describe("scriptTagOpenAndCloseFor()", async function () {
        // covered in other tests
    });

    describe("urlSafeScriptTagOpenAndCloseFor()", async function () {
        // covered in other tests
    });

    describe("fetchScript()", async function () {
        // covered in other tests
    });

    describe("sizeForBase64Encoding()", async function () {
        // covered in other tests
    });
});