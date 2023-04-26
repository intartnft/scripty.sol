// const { expect } = require("chai");
// const utilities = require("../utilities/utilities")

// const recordMode = false;
// const expectedResultsPath = __dirname + "/expectedResults/";

// const writeHTMLResult = (name, result) => {
//     const fileName = name.replace(/\s/g, '');
//     utilities.writeFile(expectedResultsPath + fileName + ".html", result)
// }

// const readExpectedHTMLResult = (name) => {
//     const fileName = name.replace(/\s/g, '');
//     const data = utilities.readFile(expectedResultsPath + fileName + ".html")
//     return data;
// }

// const expectHTML = (name, actual) => {
//     if (recordMode) {
//         writeHTMLResult(name, actual)
//         return
//     }
//     const expected = readExpectedHTMLResult(name)
//     expect(actual).to.equal(expected)
// }

// describe("ScriptyWrappedURLSafe Tests", function () {
//     const controllerScript = "controllerScript"

//     async function deploy() {
//         const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
//         await contentStore.deployed()

//         const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
//             contentStore.address
//         )
//         await scriptyStorageContract.deployed()

//         const scriptyWrappedURLSafeContract = await (await ethers.getContractFactory("ScriptyWrappedURLSafe")).deploy()
//         await scriptyWrappedURLSafeContract.deployed()

//         return { scriptyStorageContract, scriptyWrappedURLSafeContract }
//     }

//     function createControllerScriptRequestWrapped(wrapType) {
//         if (wrapType == 4) {
//             return ["", utilities.emptyAddress, 0, wrapType, utilities.stringToBytes("wrapPrefix"), utilities.stringToBytes("wrapSuffix"), utilities.stringToBytes(controllerScript)]
//         }
//         return ["", utilities.emptyAddress, 0, wrapType, utilities.emptyBytes(), utilities.emptyBytes(), utilities.stringToBytes(controllerScript)]
//     }

//     async function addHeadTag() {
//         return [
//             utilities.stringToBytes("%3Ctitle%3E"),
//             utilities.stringToBytes("%3C%2Ftitle%3E"),
//             utilities.stringToBytes("Hello%20World")
//         ]
//     }

//     async function addWrappedScripts(
//         scriptyStorageContract,
//         wrapType
//     ) {
//         const script = "wrappedScript"
//         let wrapPrefix = utilities.emptyBytes()
//         let wrapSuffix = utilities.emptyBytes()
//         let scriptContent = utilities.emptyBytes()

//         if (wrapType == 4) {
//             wrapPrefix = utilities.stringToBytes("wrapPrefix")
//             wrapSuffix = utilities.stringToBytes("wrapSuffix")
//         }

//         let scriptRequests = []

//         for (let i = 0; i < 2; i++) {
//             let scriptName = "script" + i
//             await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
//             await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(script + i))
//             scriptRequests.push([scriptName, scriptyStorageContract.address, 0, wrapType, wrapPrefix, wrapSuffix, scriptContent])
//         }

//         return { scriptRequests }
//     }

//     async function wrappedCallWithSizeCheck(title, contract, headTags, requests) {
//         const scriptSize = await contract.getBufferSizeForHTMLWrappedURLSafe(headTags, requests)
//         const invalidSize = scriptSize.sub(ethers.BigNumber.from(1))

//         const htmlRaw = await contract.getHTMLWrappedURLSafe(headTags, requests, scriptSize)
//         const htmlRawString = utilities.bytesToString(htmlRaw)

//         expectHTML(title, htmlRawString);

//         await expect(contract.getHTMLWrappedURLSafe(headTags, requests, invalidSize))
//             .to.be.revertedWith('DynamicBuffer: Appending out of bounds.');
//     }

//     describe("Store Script and get raw HTML", async function () {

//         async function wrapTypeTest(title, wrapType) {
//             const { scriptyStorageContract, scriptyWrappedURLSafeContract } = await deploy()
//             const { scriptRequests } = await addWrappedScripts(scriptyStorageContract, wrapType)

//             const headTags = [await addHeadTag()];
//             await wrappedCallWithSizeCheck(title, scriptyWrappedURLSafeContract, headTags, scriptRequests);
//         }

//         it("Store Script and get HTML - URL Safe - Wrap Type 0", async function () {
//             await wrapTypeTest(this.test.fullTitle(),0)
//         });

//         it("Store Script and get HTML - URL Safe - Wrap Type 1", async function () {
//             await wrapTypeTest(this.test.fullTitle(),1)
//         });

//         it("Store Script and get HTML - URL Safe - Wrap Type 2", async function () {
//             await wrapTypeTest(this.test.fullTitle(),2)
//         });

//         it("Store Script and get HTML - URL Safe - Wrap Type 3", async function () {
//             await wrapTypeTest(this.test.fullTitle(),3)
//         });

//         it("Store Script and get HTML - URL Safe - Wrap Type 4", async function () {
//             await wrapTypeTest(this.test.fullTitle(),4)
//         });
//     })

//     describe("Store Script and get raw HTML with controller script", async function () {

//         async function controllerScriptTest(title, wrapType) {
//             const { scriptyStorageContract, scriptyWrappedURLSafeContract } = await deploy()
//             let { scriptRequests } = await addWrappedScripts(scriptyStorageContract, 0)

//             scriptRequests.push(
//                 createControllerScriptRequestWrapped(wrapType)
//             );

//             const headTags = [await addHeadTag()];
//             await wrappedCallWithSizeCheck(title, scriptyWrappedURLSafeContract, headTags, scriptRequests);
//         }

//         it("Store Script and get HTML - URL Safe - Controller Script (wrapType 0)", async function () {
//             await controllerScriptTest(this.test.fullTitle(),0)
//         });

//         it("Store Script and get HTML - URL Safe - Controller Script (wrapType 1)", async function () {
//             await controllerScriptTest(this.test.fullTitle(),1)
//         });

//         it("Store Script and get HTML - URL Safe - Controller Script (wrapType 2)", async function () {
//             await controllerScriptTest(this.test.fullTitle(),2)
//         });

//         it("Store Script and get HTML - URL Safe - Controller Script (wrapType 3)", async function () {
//             await controllerScriptTest(this.test.fullTitle(),3)
//         });

//         it("Store Script and get HTML - URL Safe - Controller Script (wrapType 4)", async function () {
//             await controllerScriptTest(this.test.fullTitle(),4)
//         });
//     })
// });
