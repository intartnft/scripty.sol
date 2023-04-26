const path = require('path');
const utilities = require("../utilities/utilities")

describe("Scripty GZIP BASE64 Tests", function () {
    async function deploy() {
        const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
        await contentStore.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
            contentStore.address
        )
        await scriptyStorageContract.deployed()

        const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilderV2")).deploy()
        await scriptyBuilderContract.deployed()

        return { scriptyStorageContract, scriptyBuilderContract }
    }

    it("Store and read threejs.min.GZIP", async function () {
        const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

        const script0 = utilities.readFile(path.join(__dirname, "../baseScripts/dist/scriptyBase.js"))
        await scriptyStorageContract.createScript("scriptyBase", utilities.stringToBytes("scriptyBase"))
        await scriptyStorageContract.addChunkToScript("scriptyBase", utilities.stringToBytes(script0))

        // NOTE: Chunks are set to 10,000 because the theoretical limit of 24kb (24576) causes Hardhat to gas out
        // Breaking a big lib like ThreeJS into 14kb chunks will drastically increase gas costs IRL
        const threejsMinPNG = utilities.readFile(path.join(__dirname, "../examples/commonScripts/three.min.js.gz.txt"))
        const threejsMinPNGChunks = utilities.chunkSubstr(threejsMinPNG, 10000)

        await scriptyStorageContract.createScript("three.min.js.gz", utilities.stringToBytes("three.min.js.gz"))
        for (let i = 0; i < threejsMinPNGChunks.length; i++) {
            await scriptyStorageContract.addChunkToScript("three.min.js.gz", utilities.stringToBytes(threejsMinPNGChunks[i]))
        }

        const script1 = utilities.readFile(path.join(__dirname, "../baseScripts/dist/gunzipScripts-0.0.1.js"))
        await scriptyStorageContract.createScript("gunzipScripts-0.0.1", utilities.stringToBytes("gunzipScripts-0.0.1"))
        await scriptyStorageContract.addChunkToScript("gunzipScripts-0.0.1", utilities.stringToBytes(script1))

        const script2 = utilities.readFile(path.join(__dirname, "../examples/cube3D_GZIP_BASE64/scripts/cube3D_GZIP.js"))
        await scriptyStorageContract.createScript("cube3D_GZIP", utilities.stringToBytes("cube3D_GZIP"))
        await scriptyStorageContract.addChunkToScript("cube3D_GZIP", utilities.stringToBytes(script2))

        const nftContract = await (await ethers.getContractFactory("Cube3D_GZIP_BASE64")).deploy(
            scriptyStorageContract.address,
            scriptyBuilderContract.address
        )
        await nftContract.deployed()
        await nftContract.tokenURI_ForGasTest()
        // TODO: add html assert
    });
});
