const utilities = require("../utilities/utilities")

describe("ScriptyBuilder Gas Tests", function () {
	const script = "var c = document.createElement('canvas'); var ctx = c.getContext('2d'); ctx.beginPath(); ctx.rect(20, 20, 150, 100); ctx.stroke(); document.body.appendChild(c);"

	async function deploy() {
		const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
		await contentStore.deployed()

		const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
			contentStore.address
		)
		await scriptyStorageContract.deployed()

		const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilder")).deploy()
		await scriptyBuilderContract.deployed()

		const scriptyWrappedHTMLContract = await (await ethers.getContractFactory("ScriptyWrappedHTML")).deploy()
		await scriptyWrappedHTMLContract.deployed()

		const scriptyInlineHTMLContract = await (await ethers.getContractFactory("ScriptyInlineHTML")).deploy()
		await scriptyInlineHTMLContract.deployed()

		const scriptyTestContract = await (await ethers.getContractFactory("ScriptyBuilderGasTest")).deploy(
			scriptyWrappedHTMLContract.address,
			scriptyInlineHTMLContract.address
		)
		await scriptyTestContract.deployed()

		return { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract }
	}

	async function getHTMLRequest(scriptCount, scriptyStorageContract, scriptType, headRequests = []) {
		let scriptRequests = []

		let wrappedScript = script;
		if (scriptType == 1) {
			wrappedScript = utilities.toBase64String(wrappedScript)
		}else if (scriptType == 2) {
			wrappedScript = utilities.toGZIPBase64String(wrappedScript)
		}

		let totalSize = 0
		for (let i = 0; i < scriptCount; i++) {
			let scriptName = "script" + i
			await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
			await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(script))
			totalSize += script.length
			scriptRequests.push([scriptName, scriptyStorageContract.address, 0, scriptType, utilities.emptyBytes(), utilities.emptyBytes(), utilities.emptyBytes()])
		}

		return { scriptRequests, headRequests }
	}

	async function addScripts(count, scriptyStorageContract, type) {
		let scriptRequests = []

		let wrappedScript = script;
		if (type == 1) {
			wrappedScript = utilities.toBase64String(wrappedScript)
		}else if (type == 2) {
			wrappedScript = utilities.toGZIPBase64String(wrappedScript)
		}

		let totalSize = 0
		for (let i = 0; i < count; i++) {
			let scriptName = "script" + i
			await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
			await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(script))
			totalSize += script.length
			scriptRequests.push([scriptName, scriptyStorageContract.address, 0, type, utilities.emptyBytes(), utilities.emptyBytes(), utilities.emptyBytes()])
		}

		return { scriptRequests }
	}

	describe("Scripty Gas Tests - Inline", function () {
		it("Gas Test - Encoded HTML - Inline - Few", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLInline_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Inline - Many", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLInline_Many(htmlRequest)
		});
	})

	describe("Scripty Gas Tests - Wrapped", function () {
		it("Gas Test - Encoded HTML - Wrapped - Wrap Type 0 - Few", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLWrapped_WrapType_0_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Wrapped - Wrap Type 1 - Few", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLWrapped_WrapType_1_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Wrapped - Wrap Type 2 - Few", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLWrapped_WrapType_2_Few(htmlRequest)
		});

		//

		it("Gas Test - Encoded HTML - Wrapped - Wrap Type 0 - Many", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLWrapped_WrapType_0_Many(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Wrapped - Wrap Type 1 - Many", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLWrapped_WrapType_1_Many(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Wrapped - Wrap Type 2 - Many", async function () {
			const { scriptyStorageContract, scriptyBuilderContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLWrapped_WrapType_2_Many(htmlRequest)
		});
	})
});
