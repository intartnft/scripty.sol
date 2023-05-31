const hre = require("hardhat")
const deployedContracts = require("../utilities/deployedContracts")

const delay = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms))
}

async function main() {
    const networkName = hre.network.name
    console.log("Using", networkName, "network for deployment")

    const ethfs_ContentStore_Address = deployedContracts.addressFor(networkName, "ethfs_ContentStore")
    const ethfs_FileStore_Address = deployedContracts.addressFor(networkName, "ethfs_FileStore")

    // DEPLOYMENT
	const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
		ethfs_ContentStore_Address
	)
	await scriptyStorageContract.deployed()
	console.log("ScriptyStorage deployed", scriptyStorageContract.address);

	const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilderV2")).deploy()
	await scriptyBuilderContract.deployed()
	console.log("ScriptyBuilderV2 deployed", scriptyBuilderContract.address);

    const ethfsFileStorageContract = await (await ethers.getContractFactory("ETHFSFileStorage")).deploy(
        ethfs_FileStore_Address
    )
	await ethfsFileStorageContract.deployed()
	console.log("ETHFSFileStorage deployed", ethfsFileStorageContract.address);
    
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

    await hre.run("verify:verify", {
        address: ethfsFileStorageContract.address,
        constructorArguments: [
            ethfs_FileStore_Address
        ],
    });
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});