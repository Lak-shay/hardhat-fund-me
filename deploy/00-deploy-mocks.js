const { network } = require("hardhat");
const { developmentChain, DECIMALS, INITIAL_ANSWER } = require("../helper-hardhat-config");

module.exports = async (hre) => {
    // extract getnamedaccounts and deployments functions from hre
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    if (developmentChain.includes(network.name)) {
        console.log("Local Host detected. Deploying Mock!..")
        await deploy("MockV3Aggregator", {
            contract: "MockV3Aggregator",
            from: deployer,
            log: true,
            args: [DECIMALS, INITIAL_ANSWER],
        })
        console.log("Mocks Deployed")
    }
}
module.exports.tags = ["all", "mocks"]