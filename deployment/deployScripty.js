const hre = require("hardhat")
const deployedContracts = require("../utilities/deployedContracts")
const {deploy} = require("./deployWithDeployer")

async function main() {
    const networkName = hre.network.name
    console.log("Deploying to", networkName);

    const ethfsFileStoreV2Address = deployedContracts.addressFor(networkName, "ethfs_FileStore_v2");
    const deployer = deployedContracts.addressFor(networkName, "deployer")

    await deploy(deployer, "ScriptyBuilderV2", {types: [], values: []}, true)
    await deploy(deployer, "ScriptyStorageV2", {types: ["address"], values: [ethfsFileStoreV2Address]}, true)
    
    // STORAGE SOLUTIONS 

    await deploy(deployer, "ETHFSV2FileStorage", {types: ["address"], values: [ethfsFileStoreV2Address]}, true)
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});