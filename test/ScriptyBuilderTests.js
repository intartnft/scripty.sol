const { expect } = require("chai");
const utilities = require("../utilities/utilities")

const recordMode = false
const expectedResultsPath = __dirname + "/expectedResults/";

const writeHTMLResult = (name, result) => {
	const fileName = name.replace(/\s/g, '');
	utilities.writeFile(expectedResultsPath + fileName + ".html", result)
}

const readExpectedHTMLResult = (name) => {
	const fileName = name.replace(/\s/g, '');
	const data = utilities.readFile(expectedResultsPath + fileName + ".html")
	return data;
}

const expectHTML = (name, actual) => {
	if (recordMode) {
		writeHTMLResult(name, actual)
		return
	}
	const expected = readExpectedHTMLResult(name)
	expect(actual).to.equal(expected)
}

describe("ScriptyBuilder Tests", function () {
	const controllerScript = "controllerScript"

	async function deploy() {
		const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
		await contentStore.deployed()

		const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
			contentStore.address
		)
		await scriptyStorageContract.deployed()

		const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilder")).deploy()
		await scriptyBuilderContract.deployed()

		return { scriptyStorageContract, scriptyBuilderContract }
	}

	function createControllerScriptRequestWrapped(wrapType) {
		if (wrapType == 4) {
			return ["", utilities.emptyAddress, 0, wrapType, utilities.stringToBytes("wrapPrefix"), utilities.stringToBytes("wrapSuffix"), utilities.stringToBytes(controllerScript)]
		}
		return ["", utilities.emptyAddress, 0, wrapType, utilities.emptyBytes(), utilities.emptyBytes(), utilities.stringToBytes(controllerScript)]
	}

	function createControllerScriptRequestInline() {
		return ["", utilities.emptyAddress, 0, utilities.stringToBytes(controllerScript)]
	}

	async function addWrappedScripts(
		scriptyStorageContract,
		wrapType
	) {
		const script = "wrappedScript"
		let wrapPrefix = utilities.emptyBytes()
		let wrapSuffix = utilities.emptyBytes()
		let scriptContent = utilities.emptyBytes()

		if (wrapType == 4) {
			wrapPrefix = utilities.stringToBytes("wrapPrefix")
			wrapSuffix = utilities.stringToBytes("wrapSuffix")
		}

		let scriptRequests = []

		for (let i = 0; i < 2; i++) {
			let scriptName = "script" + i
			await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
			await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(script + i))
			scriptRequests.push([scriptName, scriptyStorageContract.address, 0, wrapType, wrapPrefix, wrapSuffix, scriptContent])
		}

		return { scriptRequests }
	}

	async function addInlineScripts(scriptyStorageContract, scriptContent = utilities.emptyBytes()) {
		const script = "inlineScript"
		let scriptRequests = []

		for (let i = 0; i < 2; i++) {
			let scriptName = "script" + i
			await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
			await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(script + i))
			scriptRequests.push([scriptName, scriptyStorageContract.address, 0, scriptContent])
		}

		return { scriptRequests }
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
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()

			const chunk = "chunk"

			await scriptyStorageContract.createScript("script", utilities.stringToBytes("details"))
			for (let i = 0; i < 50; i++) {
				await scriptyStorageContract.addChunkToScript("script", utilities.stringToBytes(chunk + i))
			}

			const request = ["script", scriptyStorageContract.address, 0, utilities.emptyBytes()]
			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline([request])

			const html = await scriptyBuilderContract.getHTMLInline([request], scriptSize)
			const htmlString = utilities.bytesToString(html)

			const expectedHTML = "<html><body style='margin:0;'><script>chunk0chunk1chunk2chunk3chunk4chunk5chunk6chunk7chunk8chunk9chunk10chunk11chunk12chunk13chunk14chunk15chunk16chunk17chunk18chunk19chunk20chunk21chunk22chunk23chunk24chunk25chunk26chunk27chunk28chunk29chunk30chunk31chunk32chunk33chunk34chunk35chunk36chunk37chunk38chunk39chunk40chunk41chunk42chunk43chunk44chunk45chunk46chunk47chunk48chunk49</script></body></html>"
			expect(expectedHTML).to.equal(htmlString)
		})
	})

	describe("Store Script and get raw HTML", async function () {
		it("Store Script and get HTML - Wrapped - Wrap Type 0", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Wrap Type 1", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 1)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Wrap Type 2", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 2)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Wrap Type 3", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 3)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Wrap Type 4", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 4)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Inline", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Wrap Type 0", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Wrap Type 1", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 1)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Wrap Type 2", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 2)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Wrap Type 3", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 3)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Wrap Type 4", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 4)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});
	})

	describe("Store Script and get raw HTML with controller script", async function () {
		it("Store Script and get HTML - Wrapped - Controller Script (wrapType 0)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Controller Script (wrapType 1)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(1)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Controller Script (wrapType 2)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(2)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Controller Script (wrapType 3)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(3)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Controller Script (wrapType 4)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(4)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Controller Script at beginning", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.splice(0, 0,
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Controller Script in middle", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.splice(1, 0,
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Wrapped - Controller Script at the end", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Inline - Controller Script at beginning", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			scriptRequests.splice(0, 0,
				createControllerScriptRequestInline()
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Inline - Controller Script in middle", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			scriptRequests.splice(1, 0,
				createControllerScriptRequestInline()
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - Inline - Controller Script at the end", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			scriptRequests.push(
				createControllerScriptRequestInline()
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		// 

		it("Store Script and get HTML - URL Safe - Controller Script (wrapType 0)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Controller Script (wrapType 1)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(1)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Controller Script (wrapType 2)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(2)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Controller Script (wrapType 3)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(3)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get HTML - URL Safe - Controller Script (wrapType 4)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(4)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getHTMLWrappedURLSafe(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});
	})

	describe("Store Script and get encoded HTML", async function () {
		it("Store Script and get Encoded HTML - Wrapped - Wrap Type 0", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Wrap Type 1", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 1)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Wrap Type 2", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 2)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Wrap Type 3", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 3)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Wrap Type 4", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 4)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Inline", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			const { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});
	})

	describe("Store Script and get Encoded HTML with controller script", async function () {

		it("Store Script and get Encoded HTML - Wrapped - Controller Script (wrapType 0)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Controller Script (wrapType 1)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(1)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Controller Script (wrapType 2)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(2)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Controller Script (wrapType 3)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(3)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Controller Script (wrapType 4)", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(4)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Controller Script at beginning", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.splice(0, 0,
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Controller Script in middle", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.splice(1, 0,
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Wrapped - Controller Script at the end", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

			scriptRequests.push(
				createControllerScriptRequestWrapped(0)
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLWrapped(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLWrapped(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Inline - Controller Script at beginning", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			scriptRequests.splice(0, 0,
				createControllerScriptRequestInline()
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Inline - Controller Script in middle", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			scriptRequests.splice(1, 0,
				createControllerScriptRequestInline()
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});

		it("Store Script and get Encoded HTML - Inline - Controller Script at the end", async function () {
			const { scriptyStorageContract, scriptyBuilderContract } = await deploy()
			let { scriptRequests } = await addInlineScripts(scriptyStorageContract)

			scriptRequests.push(
				createControllerScriptRequestInline()
			);

			const scriptSize = await scriptyBuilderContract.getBufferSizeForHTMLInline(scriptRequests)
			const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

			const html = await scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, scriptSize)
			const htmlString = utilities.bytesToString(html)

			const htmlRaw = await scriptyBuilderContract.getHTMLInline(scriptRequests, scriptSize)
			const htmlRawString = utilities.bytesToString(htmlRaw)
			
			expect(htmlRawString).to.be.equal(utilities.parseBase64DataURI(htmlString))
			expectHTML(this.test.fullTitle(), htmlString);

			await expect(scriptyBuilderContract.getEncodedHTMLInline(scriptRequests, invalidSize))
				.to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
		});
	})
});
