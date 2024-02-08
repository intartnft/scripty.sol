const hre = require("hardhat")

const delay = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms))
}

const deploy = async (deployer, contractName, arguments, verify) => {
    const [owner] = await ethers.getSigners();

    const networkName = hre.network.name
    console.log("Using", networkName, "network for deployment")

    const contractFactory = await ethers.getContractFactory(contractName)
    const salt = ethers.utils.formatBytes32String("")
    const encodedArguments = ethers.utils.defaultAbiCoder.encode(arguments.types, arguments.values);

    const initCode = ethers.utils.hexConcat([
        contractFactory.bytecode,
        encodedArguments
    ])
    const initCodeHash = ethers.utils.keccak256(initCode)
    const deployAddress = ethers.utils.getCreate2Address(deployer, salt, initCodeHash);

    const verifyContract = async (shouldWait) => {
        if (shouldWait) {
            await delay(30000)
        }
        
        try {
            await hre.run("verify:verify", {
                address: deployAddress,
                constructorArguments: arguments.values
            });   
        } catch (error) {
            console.error(error.message)
        }
    }

    const foundByteCode = await ethers.provider.getCode(deployAddress);
    if (foundByteCode != "0x") {
        console.log("Already deployed ", contractName, " to ", deployAddress);
        if (verify) {
            await verifyContract(false)
        }
        return
    }

    console.log("Deploying ", contractName, " to ", deployAddress);

    const tx = {
        to: deployer,
        data: ethers.utils.hexConcat([
            salt,
            initCode
        ])
    };

    const transaction = await owner.sendTransaction(tx)
    const receipt = await transaction.wait()
    console.log(receipt.transactionHash);
    
    if (verify) {
        await verifyContract(true)
    }
}

exports.deploy = deploy