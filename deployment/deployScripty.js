const hre = require("hardhat")
const deployedContracts = require("../utilities/deployedContracts")

const delay = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms))
}

async function main() {
    const networkName = hre.network.name
    console.log("Using", networkName, "network for deployment")

    const ethfs_FileStore_v2_Address = deployedContracts.addressFor(networkName, "ethfs_FileStore_v2")

    // DEPLOYMENT
	const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorageV2")).deploy(
		ethfs_FileStore_v2_Address
	)
	await scriptyStorageContract.deployed()
	console.log("ScriptyStorageV2 deployed", scriptyStorageContract.address);

	const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilderV2")).deploy()
	await scriptyBuilderContract.deployed()
	console.log("ScriptyBuilderV2 deployed", scriptyBuilderContract.address);

    const ethFSV2FileStorage = await (await ethers.getContractFactory("ETHFSV2FileStorage")).deploy(
        ethfs_FileStore_v2_Address
    )
	await ethFSV2FileStorage.deployed()
	console.log("ETHFSV2FileStorage deployed", ethFSV2FileStorage.address);

    // Wait for a minute for bytecode index
    console.log("Waiting for a minute for bytecode index on Etherscan");
    await delay(60000)

    // VERIFICATION
    await hre.run("verify:verify", {
        address: scriptyStorageContract.address,
        constructorArguments: [
            ethfs_ContentStore_Address
        ],
    });

    await hre.run("verify:verify", {
        address: scriptyBuilderContract.address
    });
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});