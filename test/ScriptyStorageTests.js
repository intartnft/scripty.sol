const { expect } = require("chai");
const utilities = require("../utilities/utilities")

describe.only("ScriptyStorage Tests", function () {
    async function deploy() {
        const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
        await contentStore.deployed()

        const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
            contentStore.address
        )
        await scriptyStorageContract.deployed()

        return { scriptyStorageContract }
    }

    describe("Script ownage tests", async function () {
        it("Try to create already created script", async function () {
            const { scriptyStorageContract } = await deploy()

            await scriptyStorageContract.createScript("script", utilities.stringToBytes("details"))

            await expect(scriptyStorageContract.createScript("script", utilities.stringToBytes("details")))
                .to.be.revertedWithCustomError(scriptyStorageContract, "ScriptExists")
        })

        it("Try to add chunk to not owned script", async function () {
            const [owner, addr1] = await ethers.getSigners();
            const { scriptyStorageContract } = await deploy()

            await scriptyStorageContract.createScript("script1", utilities.stringToBytes("script1"))
            await scriptyStorageContract.addChunkToScript("script1", utilities.stringToBytes("chunk1"))

            const addr1ScriptyContract = scriptyStorageContract.connect(addr1)
            await addr1ScriptyContract.createScript("script2", utilities.stringToBytes("script2"))
            await addr1ScriptyContract.addChunkToScript("script2", utilities.stringToBytes("chunk1"))

            await expect(addr1ScriptyContract.addChunkToScript("script1", utilities.stringToBytes("chunk2")))
                .to.be.revertedWithCustomError(scriptyStorageContract, "NotScriptOwner")
        })

        it("Try to update details of not owned script", async function () {
            const [owner, addr1] = await ethers.getSigners();
            const { scriptyStorageContract } = await deploy()

            await scriptyStorageContract.createScript("script1", utilities.stringToBytes("script1"))
            await scriptyStorageContract.updateDetails("script1", utilities.stringToBytes("script1 new details"))

            const addr1ScriptyContract = scriptyStorageContract.connect(addr1)
            await addr1ScriptyContract.createScript("script2", utilities.stringToBytes("script2"))
            await addr1ScriptyContract.updateDetails("script2", utilities.stringToBytes("script2 new details"))

            await expect(addr1ScriptyContract.updateDetails("script1", utilities.stringToBytes("script1 test details")))
                .to.be.revertedWithCustomError(scriptyStorageContract, "NotScriptOwner")
        })

        it("Add chunks", async function () {
            const { scriptyStorageContract } = await deploy()

            const chunk = "chunk"

            await scriptyStorageContract.createScript("script", utilities.stringToBytes("details"))
            for (let i = 0; i < 50; i++) {
                await scriptyStorageContract.addChunkToScript("script", utilities.stringToBytes(chunk + i))
            }

            const storedScript = await scriptyStorageContract.getScript("script", utilities.emptyBytes())
            const storedScriptString = utilities.bytesToString(storedScript)

            const expectedScriptString = "chunk0chunk1chunk2chunk3chunk4chunk5chunk6chunk7chunk8chunk9chunk10chunk11chunk12chunk13chunk14chunk15chunk16chunk17chunk18chunk19chunk20chunk21chunk22chunk23chunk24chunk25chunk26chunk27chunk28chunk29chunk30chunk31chunk32chunk33chunk34chunk35chunk36chunk37chunk38chunk39chunk40chunk41chunk42chunk43chunk44chunk45chunk46chunk47chunk48chunk49"
            expect(storedScriptString).to.equal(expectedScriptString)
        })

        it("Freeze script", async function () {
            const { scriptyStorageContract } = await deploy()

            const chunk = "chunk"

            await scriptyStorageContract.createScript("script", utilities.stringToBytes("details"))
            for (let i = 0; i < 50; i++) {
                await scriptyStorageContract.addChunkToScript("script", utilities.stringToBytes(chunk + i))
            }

            await scriptyStorageContract.freezeScript("script")

            await expect(scriptyStorageContract.addChunkToScript("script", utilities.stringToBytes(chunk)))
                .to.be.revertedWithCustomError(scriptyStorageContract, "ScriptIsFrozen")

            scriptyStorageContract.updateDetails("script", utilities.stringToBytes("updated details"))
            const scriptInStorage = await scriptyStorageContract.scripts("script")
            const scriptDetailsString = utilities.bytesToString(scriptInStorage.details)

            expect(scriptDetailsString).to.equal("updated details")
        })
    })
});
