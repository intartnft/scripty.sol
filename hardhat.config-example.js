/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('hardhat-ignore-warnings');
require('hardhat-abi-exporter');
require("dotenv").config();

module.exports = {
    solidity: {
        version: "0.8.22",
        settings: {
            optimizer: {
                enabled: true,
                runs: 500
            }
        }
    },
    mocha: {
        timeout: 100000000
    },
    networks: {
        localhost: {
            blockGasLimit: 500000000,
            timeout: 100000000,
            forking: {
                url: process.env.ETHEREUM_PROVIDER
            },
        },
        hardhat: {
            blockGasLimit: 500000000,
            timeout: 100000000,
            forking: {
                url: process.env.ETHEREUM_PROVIDER
            },
        },
        ethereum: {
            url: process.env.ETHEREUM_PROVIDER,
            accounts: [process.env.ETHEREUM_PRIVATE_KEY],
        },
        eth_goerli: {
            url: process.env.ETH_GOERLI_PROVIDER,
            accounts: [process.env.ETH_GOERLI_PRIVATE_KEY],
        },
        eth_sepolia: {
            url: process.env.ETH_SEPOLIA_PROVIDER,
            accounts: [process.env.ETH_SEPOLIA_PRIVATE_KEY],
        },
        base: {
            url: process.env.BASE_PROVIDER,
            accounts: [process.env.BASE_PRIVATE_KEY],
        },
        base_sepolia: {
            url: process.env.BASE_SEPOLIA_PROVIDER,
            accounts: [process.env.BASE_SEPOLIA_PRIVATE_KEY],
        },
        optimism: {
            url: process.env.OPTIMISM_PROVIDER,
            accounts: [process.env.OPTIMISM_PRIVATE_KEY],
        },
        optimism_sepolia: {
            url: process.env.OPTIMISM_SEPOLIA_PROVIDER,
            accounts: [process.env.OPTIMISM_SEPOLIA_PRIVATE_KEY],
        }
    },
    etherscan: {
        apiKey: {
            ethereum: process.env.ETHEREUM_ETHERSCAN_APIKEY,
            goerli: process.env.ETHEREUM_ETHERSCAN_APIKEY,
            sepolia: process.env.ETHEREUM_ETHERSCAN_APIKEY,
            
            base: process.env.BASE_ETHERSCAN_APIKEY,
            base_sepolia: process.env.BASE_ETHERSCAN_APIKEY,
            optimism: process.env.OPTIMISM_ETHERSCAN_APIKEY,
            optimism_sepolia: process.env.OPTIMISM_SEPOLIA_ETHERSCAN_APIKEY
        },
        customChains: [
            {
                network: "base",
                chainId: 8453,
                urls: {
                    apiURL: "https://api.basescan.org/api",
                    browserURL: "https://basescan.org"
                }
            },
            {
                network: "base_sepolia",
                chainId: 84532,
                urls: {
                    apiURL: "https://api-sepolia.basescan.org/api",
                    browserURL: "https://sepolia.basescan.org"
                }
            },
            {
                network: "optimism",
                chainId: 10,
                urls: {
                    apiURL: "https://api-optimistic.etherscan.io/api",
                    browserURL: "https://optimistic.etherscan.io/"
                }
            },
            {
                network: "optimism_sepolia",
                chainId: 11155420,
                urls: {
                    apiURL: "https://api-sepolia-optimism.etherscan.io/api",
                    browserURL: "https://https://sepolia-optimism.etherscan.io/"
                }
            }
        ]
    },
    gasReporter: {
        currency: 'USD',
        enabled: true
    },
    abiExporter: {
        path: './data/abi',
        runOnCompile: true
    },
};