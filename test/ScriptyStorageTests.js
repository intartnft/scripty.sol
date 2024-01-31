const { expect } = require("chai");
const utilities = require("../utilities/utilities")
const { byteLength, bytesToString } = require("../utilities/utilities");

const SAFE_SINGLETON_FACTORY = "0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7";
const SAFE_SINGLETON_FACTORY_BYTECODE = "0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3";

describe("ScriptyStorage Tests", function () {
    async function deploy() {

        await network.provider.send("hardhat_setCode", [
            SAFE_SINGLETON_FACTORY,
            SAFE_SINGLETON_FACTORY_BYTECODE,
        ]);

        const ethfsFileStoreContract = await (await ethers.getContractFactory("FileStore")).deploy(
            SAFE_SINGLETON_FACTORY
        )
        await ethfsFileStoreContract.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorageV2")).deploy(
            ethfsFileStoreContract.address
        )
        await scriptyStorageContract.deployed()

        return { scriptyStorageContract, ethfsFileStoreContract }
    }

    let chunk = "chunk"
    let chunkData = utilities.stringToBytes(chunk);
    let finalChunkString = "";

    async function addChunk(chunkCount) {
        // reset
        finalChunkString = "";

        for (let i = 0; i < chunkCount; i++) {
            const chunkData = utilities.stringToBytes(chunk + i)
            finalChunkString += `${chunk}${i}`

            await expect(scriptyStorageContract.addChunkToContent("content", chunkData))
                .to.emit(scriptyStorageContract, "ChunkStored")
                .withArgs("content", bytesToString(chunkData).length);
        }

        // Test the final output is as expected
        const storedContent = await scriptyStorageContract.getContent("content", utilities.emptyBytes())
        const storedContentString = utilities.bytesToString(storedContent)
        expect(storedContentString).to.equal(finalChunkString)
    }

    let owner, addr1;
    let scriptyStorageContract;
    let ethfsFileStoreContract;

    const details = utilities.stringToBytes("details");
    const newDetails = utilities.stringToBytes("details2");

    beforeEach(async () => {
        [owner, addr1] = await ethers.getSigners();
        ({scriptyStorageContract, ethfsFileStoreContract} = await deploy());
    });

    describe("createContent()", async function () {
        it("Create Content", async function () {
            await expect(scriptyStorageContract.createContent("content", details))
                .to.emit(scriptyStorageContract, "ContentCreated")
                .withArgs("content", details);
        });

        it("Fail to create content with duplicate name", async function () {
            await scriptyStorageContract.createContent("content", details)
            await expect(
                scriptyStorageContract.connect(addr1).createContent("content", details)
            ).to.be.revertedWithCustomError(scriptyStorageContract, "ContentExists");
        });
    });

    describe("addChunkToContent()", async function () {

        beforeEach(async () => {
            await scriptyStorageContract.createContent("content", details)
        });

        it("Add chunk", async function () {
            await addChunk(1);
        });

        it("Add multiple chunks", async function () {
            await addChunk(10);
        });

        it("Fail to add chunk as non-owner", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).addChunkToContent("content", chunkData)
            ).to.be.revertedWithCustomError(scriptyStorageContract, "NotContentOwner");
        });

        it("Fail to add chunk as owner when frozen", async function () {
            await scriptyStorageContract.freezeContent("content");
            await expect(
                scriptyStorageContract.addChunkToContent("content", chunkData)
            ).to.be.revertedWithCustomError(scriptyStorageContract, "ContentIsFrozen");
        });
    });

    describe("submitToEthFSFileStore()", async function () {

        beforeEach(async () => {
            await scriptyStorageContract.createContent("content", utilities.stringToBytes("details"))
        });

        it("Update details as owner", async function () {
            await expect(scriptyStorageContract.updateDetails("content", newDetails))
                .to.emit(scriptyStorageContract, "ContentDetailsUpdated")
                .withArgs("content", newDetails);
        });

        it("Fail to update details as non-owner", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).updateDetails("content", newDetails)
            ).to.be.revertedWithCustomError(scriptyStorageContract, "NotContentOwner");
        });

        it("Fail to update details as owner when frozen", async function () {
            await scriptyStorageContract.freezeContent("content");
            await expect(
                scriptyStorageContract.updateDetails("content", newDetails)
            ).to.be.revertedWithCustomError(scriptyStorageContract, "ContentIsFrozen");
        });
    });

    describe("freezeContent()", async function () {

        beforeEach(async () => {
            await scriptyStorageContract.createContent("content", utilities.stringToBytes("details"))
        });

        it("Freeze content as owner", async function () {
            await expect(scriptyStorageContract.freezeContent("content"))
                .to.emit(scriptyStorageContract, "ContentFrozen")
                .withArgs("content");
        });

        it("Fail to freeze content as non-owner", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).freezeContent("content")
            ).to.be.revertedWithCustomError(scriptyStorageContract, "NotContentOwner");
        });

        it("Fail to freeze content when frozen", async function () {
            await scriptyStorageContract.freezeContent("content");
            await expect(
                scriptyStorageContract.freezeContent("content")
            ).to.be.revertedWithCustomError(scriptyStorageContract, "ContentIsFrozen");
        });
    });

    describe("getContentChunkPointers()", async function () {

        beforeEach(async () => {
            await scriptyStorageContract.createContent("content", details)
        });

        it("Get content pointers", async function () {
            await addChunk(10);
            const pointers = await scriptyStorageContract.getContentChunkPointers("content");
            expect(pointers.length).to.eq(10);
        });
    });

    describe("submitToEthFSFileStore()", async function () {
        beforeEach(async () => {
            await scriptyStorageContract.createContent("content", details)
        });

        it("Submit content to EthFS", async function () {
            await expect(
                scriptyStorageContract.connect(addr1).submitToEthFSFileStore("content", utilities.emptyBytes())
            ).to.be.revertedWithCustomError(scriptyStorageContract, "NotContentOwner");

            await addChunk(10);
            await scriptyStorageContract.submitToEthFSFileStore("content", utilities.emptyBytes());

            const dataFromScriptyStorage = await scriptyStorageContract.getContent("content", utilities.emptyBytes())
            const dataFromEthfsFileStore = await ethfsFileStoreContract.readFile("content")

            expect(utilities.bytesToString(dataFromScriptyStorage)).to.equal(dataFromEthfsFileStore)

            await expect(
                scriptyStorageContract.submitToEthFSFileStore("content", utilities.emptyBytes())
            ).to.be.revertedWithCustomError(ethfsFileStoreContract, "FilenameExists");
        });
    });

    describe("submitToEthFSFileStoreWithFileName()", async function () {
        beforeEach(async () => {
            await scriptyStorageContract.createContent("content", details)
        });

        it("Submit content to EthFS with file name", async function () {
            await addChunk(10);
            await expect(
                scriptyStorageContract.connect(addr1).submitToEthFSFileStoreWithFileName("content", "someFile", utilities.emptyBytes())
            ).to.be.revertedWithCustomError(scriptyStorageContract, "NotContentOwner");

            await scriptyStorageContract.submitToEthFSFileStoreWithFileName("content", "someFile", utilities.emptyBytes());

            const dataFromScriptyStorage = await scriptyStorageContract.getContent("content", utilities.emptyBytes())
            const dataFromEthfsFileStore = await ethfsFileStoreContract.readFile("someFile")

            expect(utilities.bytesToString(dataFromScriptyStorage)).to.equal(dataFromEthfsFileStore)
        });
    });
});