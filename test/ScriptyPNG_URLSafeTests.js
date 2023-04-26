const path = require('path');
const utilities = require("../utilities/utilities")

describe("Scripty PNG URL Safe Tests", function () {
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

    it("Store and read threejs.min.PNG", async function () {
        const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

        const script0 = utilities.readFile(path.join(__dirname, "../baseScripts/dist/scriptyBase.js"))
        await scriptyStorageContract.createScript("scriptyBase", utilities.stringToBytes("scriptyBase"))
        await scriptyStorageContract.addChunkToScript("scriptyBase", utilities.stringToBytes(script0))

        // NOTE: Chunks are set to 10,000 because the theoretical limit of 24kb (24576) causes Hardhat to gas out
        // Breaking a big lib like ThreeJS into 14kb chunks will drastically increase gas costs IRL
        const threejsMinPNG = utilities.readFile(path.join(__dirname, "../examples/commonScripts/threejs.min.js.png.txt"))
        const threejsMinPNGChunks = utilities.chunkSubstr(threejsMinPNG, 10000)

        await scriptyStorageContract.createScript("threejs.min.js.png", utilities.stringToBytes("threejs.min.js.png"))
        for (let i = 0; i < threejsMinPNGChunks.length; i++) {
            await scriptyStorageContract.addChunkToScript("threejs.min.js.png", utilities.stringToBytes(threejsMinPNGChunks[i]))
        }

        const script1 = utilities.readFile(path.join(__dirname, "../baseScripts/dist/injectPNGScripts-0.0.1.js"))
        await scriptyStorageContract.createScript("injectPNGScripts-0.0.1", utilities.stringToBytes("injectPNGScripts-0.0.1"))
        await scriptyStorageContract.addChunkToScript("injectPNGScripts-0.0.1", utilities.stringToBytes(script1))

        const script2 = utilities.readFile(path.join(__dirname, "../examples/cube3D_PNG_URLSafe/scripts/cube3D.js"))
        await scriptyStorageContract.createScript("cube3D", utilities.stringToBytes("cube3D"))
        await scriptyStorageContract.addChunkToScript("cube3D", utilities.stringToBytes(script2))

        const nftContract = await (await ethers.getContractFactory("Cube3D_PNG_URLSafe")).deploy(
            scriptyStorageContract.address,
            scriptyBuilderContract.address
        )
        await nftContract.deployed()
        await nftContract.tokenURI_ForGasTest()
    });
});
