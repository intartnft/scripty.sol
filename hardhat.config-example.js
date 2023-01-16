/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('hardhat-ignore-warnings');
require("dotenv").config();

// KEYS
const ETHEREUM_PRIVATE_KEY = process.env.ETHEREUM_PRIVATE_KEY
    || '0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3'; // well known private key

const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY ||
    '0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3'; // well known private key

module.exports = {
    solidity: {
        version: "0.8.17",
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
            blockGasLimit: 50000000,
            timeout: 100000000
        },
        hardhat: {
            blockGasLimit: 50000000
        },
        ethereum: {
            url: process.env.ETHEREUM_PROVIDER || 'http://127.0.0.1:8555',
            accounts: [ETHEREUM_PRIVATE_KEY],
        },
        goerli: {
            url: process.env.GOERLI_PROVIDER || 'http://127.0.0.1:8555',
            accounts: [GOERLI_PRIVATE_KEY],
        },
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_APIKEY
    },
    gasReporter: {
        enabled: true
    }
};