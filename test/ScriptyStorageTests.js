const { expect } = require("chai");
const utilities = require("../utilities/utilities")
const {byteLength, bytesToString} = require("../utilities/utilities");

describe("ScriptyStorage Tests", function () {
    async function deploy() {
        const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
        await contentStore.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
            contentStore.address
        )
        await scriptyStorageContract.deployed()

        return { scriptyStorageContract }
    }

    let chunk = "chunk"
    let chunkData = utilities.stringToBytes(chunk);
    let finalChunkString = "";

    async function addChunk(chunkCount) {
        // reset
        finalChunkString = "";

        for(let i = 0; i < chunkCount; i++) {
            const chunkData = utilities.stringToBytes(chunk + i)
            finalChunkString += `${chunk}${i}`

            await expect(scriptyStorageContract.addChunkToScript("script", chunkData))
                .to.emit(scriptyStorageContract, "ChunkStored")
                .withArgs("script", bytesToString(chunkData).length);
        }

        // Test the final output is as expected
        const storedScript = await scriptyStorageContract.getScript("script", utilities.emptyBytes())
        const storedScriptString = utilities.bytesToString(storedScript)
        expect(storedScriptString).to.equal(finalChunkString)
    }

    let owner, addr1;
    let scriptyStorageContract;

    const details = utilities.stringToBytes("details");
    const newDetails = utilities.stringToBytes("details2");

    beforeEach( async() => {
        [owner, addr1] = await ethers.getSigners();
        const obj = await deploy()
        scriptyStorageContract = obj.scriptyStorageContract;
    });

    describe("createScript()", async function () {
        it("Create Script", async function () {
            await expect(scriptyStorageContract.createScript("script", details))
                .to.emit(scriptyStorageContract, "ScriptCreated")
                .withArgs("script", details);
        });

        it("Fail to create script with duplicate name", async function () {
            await scriptyStorageContract.createScript("script", details)
            await expect(
                scriptyStorageContract.connect(addr1).createScript("script", details)
            ).to.be.revertedWithCustomError(scriptyStorageContract,"ScriptExists");
        });
    });

    describe("addChunkToScript()", async function () {

        beforeEach( async() => {
            await scriptyStorageContract.createScript("script", details)
        });

        it("Add chunk", async function () {
            await addChunk(1);
        });

        it("Add multiple chunks", async function () {
            await addChunk(10);
        });

        it("Fail to add chunk as non-owner", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).addChunkToScript("script", chunkData)
            ).to.be.revertedWithCustomError(scriptyStorageContract,"NotScriptOwner");
        });

        it("Fail to add chunk as owner when frozen", async function () {
            await scriptyStorageContract.freezeScript("script");
            await expect(
                scriptyStorageContract.addChunkToScript("script", chunkData)
            ).to.be.revertedWithCustomError(scriptyStorageContract,"ScriptIsFrozen");
        });
    });

    describe("updateDetails()", async function () {

        beforeEach( async() => {
            await scriptyStorageContract.createScript("script", utilities.stringToBytes("details"))
        });

        it("Update details as owner", async function () {
            await expect(scriptyStorageContract.updateDetails("script", newDetails))
                .to.emit(scriptyStorageContract, "ScriptDetailsUpdated")
                .withArgs("script", newDetails);
        });

        it("Fail to update details as non-owner", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).updateDetails("script", newDetails)
            ).to.be.revertedWithCustomError(scriptyStorageContract,"NotScriptOwner");
        });

        it("Fail to update details as owner when frozen", async function () {
            await scriptyStorageContract.freezeScript("script");
            await expect(
                scriptyStorageContract.updateDetails("script", newDetails)
            ).to.be.revertedWithCustomError(scriptyStorageContract,"ScriptIsFrozen");
        });
    });

    describe("updateScriptVerification()", async function () {

        beforeEach( async() => {
            await scriptyStorageContract.createScript("script", utilities.stringToBytes("details"))
        });

        it("Set verification to true as owner", async function () {
            await expect(scriptyStorageContract.updateScriptVerification("script", true))
                .to.emit(scriptyStorageContract, "ScriptVerificationUpdated")
                .withArgs("script", true);
        });

        it("Fail to set verification to true as non-owner", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).updateScriptVerification("script", true)
            ).to.be.revertedWithCustomError(scriptyStorageContract,"NotScriptOwner");
        });

        it("Fail to set verification to true as owner when frozen", async function () {
            await scriptyStorageContract.freezeScript("script");
            await expect(
                scriptyStorageContract.updateScriptVerification("script", true)
            ).to.be.revertedWithCustomError(scriptyStorageContract,"ScriptIsFrozen");
        });
    });

    describe("freezeScript()", async function () {

        beforeEach( async() => {
            await scriptyStorageContract.createScript("script", utilities.stringToBytes("details"))
        });

        it("Freeze script as owner", async function () {
            await expect(scriptyStorageContract.freezeScript("script"))
                .to.emit(scriptyStorageContract, "ScriptFrozen")
                .withArgs("script");
        });

        it("Fail to freeze script as non-owner", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).freezeScript("script")
            ).to.be.revertedWithCustomError(scriptyStorageContract,"NotScriptOwner");
        });

        it("Fail to freeze script when frozen", async function () {
            await scriptyStorageContract.freezeScript("script");
            await expect(
                scriptyStorageContract.freezeScript("script")
            ).to.be.revertedWithCustomError(scriptyStorageContract,"ScriptIsFrozen");
        });
    });

    describe("getScriptChunkPointers()", async function () {

        beforeEach( async() => {
            await scriptyStorageContract.createScript("script", details)
        });

        it("Get script pointers", async function () {
            await addChunk(10);
            const pointers = await scriptyStorageContract.getScriptChunkPointers("script");
            expect(pointers.length).to.eq(10);
        });
    });
});
