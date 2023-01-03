// function deployFunc() {
//     console.log("Hi")
// }

// module.exports.default = deployFunc;
const { network } = require("hardhat")
const { networkConfig, developmentChain } = require("../helper-hardhat-config");

// hre = hardhat runtime environment
module.exports = async (hre) => {
    // extract getnamedaccounts and deployments functions from hre
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let ethUsdPriceFeedAddress;
    if (developmentChain.includes(network.name)) {
        // development chain
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address;
    }

    else {
        // mainnet chain
        ethUsdPriceFeedAddress = networkConfig[chainId]["address"];
    }

    log("----------------------------------------------------")
    log("Deploying FundMe and waiting for confirmations...")
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: [ethUsdPriceFeedAddress],
        log: true,
        // we need to wait if on a live network so we can verify properly
        // waitConfirmations: network.config.blockConfirmations || 1,
    })
    console.log(`FundMe deployed at ${fundMe.address}`)
}

module.exports.tags = ["all", "fundme"]


// NATSPEC
/** @title  This is the title
 * @dev This is for the devs
 */ 