const utilities = require("./utilities")
const path = require('path');

exports.getContractAddresses = () => {
    const data = utilities.readFile(path.join(__dirname, "../deployment.json"))
    return JSON.parse(data)
}

const addresses = this.getContractAddresses()

exports.addressFor = (networkName, name) => {
    return addresses[networkName][name]
}