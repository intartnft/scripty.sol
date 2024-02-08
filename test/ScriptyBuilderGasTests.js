const utilities = require("../utilities/utilities")

describe("ScriptyBuilder Gas Tests", function () {
	const script = "var c = document.createElement('canvas'); var ctx = c.getContext('2d'); ctx.beginPath(); ctx.rect(20, 20, 150, 100); ctx.stroke(); document.body.appendChild(c);"
	const urlSafeScript = "var%2520c%2520%253D%2520document.createElement%2528%2527canvas%2527%2529%253B%2520var%2520ctx%2520%253D%2520c.getContext%2528%25272d%2527%2529%253B%2520ctx.beginPath%2528%2529%253B%2520ctx.rect%252820%252C%252020%252C%2520150%252C%2520100%2529%253B%2520ctx.stroke%2528%2529%253B%2520document.body.appendChild%2528c%2529%253B"

	async function deploy() {
		const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyMockStorage")).deploy()
		await scriptyStorageContract.deployed()

		const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilderV2")).deploy()
		await scriptyBuilderContract.deployed()

		const scriptyTestContract = await (await ethers.getContractFactory("ScriptyBuilderGasTest")).deploy(
			scriptyBuilderContract.address
		)
		await scriptyTestContract.deployed()

		return { scriptyStorageContract, scriptyTestContract }
	}

	async function getHTMLRequest(tagCount, scriptyStorageContract, tagType) {
		let bodyTags = []
		let headTags = []

		for (let i = 0; i < tagCount; i++) {
            headTags.push(["", utilities.emptyAddress, 0, 0, utilities.stringToBytes("<title>"), utilities.stringToBytes("</title>"), utilities.stringToBytes("Hello World")])
        }

		for (let i = 0; i < tagCount; i++) {
			let scriptName = "script" + i
			await scriptyStorageContract.addChunkToContent(scriptName, utilities.stringToBytes(script))
			bodyTags.push([scriptName, scriptyStorageContract.address, 0, tagType, utilities.emptyBytes(), utilities.emptyBytes(), utilities.emptyBytes()])
		}
		return { bodyTags, headTags }
	}

	async function getURLSafeHTMLRequest(tagCount, scriptyStorageContract, tagType) {
		let bodyTags = []
		let headTags = []

        for (let i = 0; i < tagCount; i++) {
            headTags.push(["", utilities.emptyAddress, 0, 0, utilities.stringToBytes("%3Ctitle%3E"), utilities.stringToBytes("%3C%2Ftitle%3E"), utilities.stringToBytes("Hello%20World")])
        }
		
		for (let i = 0; i < tagCount; i++) {
			let scriptName = "script" + i
			await scriptyStorageContract.addChunkToContent(scriptName, utilities.stringToBytes(urlSafeScript))
			bodyTags.push([scriptName, scriptyStorageContract.address, 0, tagType, utilities.emptyBytes(), utilities.emptyBytes(), utilities.emptyBytes()])
		}
		return { bodyTags, headTags }
	}


	describe("Scripty Gas Tests - HTML", function () {
		it("Gas Test - Encoded HTML - Script Type 0 - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0)

			await scriptyTestContract.getEncodedHTML_TagType_0_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 1 - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0)

			await scriptyTestContract.getEncodedHTML_TagType_1_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 2 - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0)

			await scriptyTestContract.getEncodedHTML_TagType_2_Few(htmlRequest)
		});

		//

		it("Gas Test - Encoded HTML - Script Type 0 - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(50, scriptyStorageContract, 0)

			await scriptyTestContract.getEncodedHTML_TagType_0_Many(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 1 - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(50, scriptyStorageContract, 0)

			await scriptyTestContract.getEncodedHTML_TagType_1_Many(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 2 - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(50, scriptyStorageContract, 0)

			await scriptyTestContract.getEncodedHTML_TagType_2_Many(htmlRequest)
		});
	})

	describe("Scripty Gas Tests - URL Safe", function () {
		it("Gas Test - URL Safe - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getURLSafeHTMLRequest(2, scriptyStorageContract, 0)

			await scriptyTestContract.getHTMLURLSafe_Few(htmlRequest)
		});

		it("Gas Test - URL Safe - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getURLSafeHTMLRequest(50, scriptyStorageContract, 0)

			await scriptyTestContract.getHTMLURLSafe_Many(htmlRequest)
		});
	})
});
