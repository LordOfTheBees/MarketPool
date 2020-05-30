const MarketsData = artifacts.require("./markets/MarketsData.sol");
const MarketFunctions = artifacts.require("./markets/MarketFunctions.sol");

module.exports = async function(deployer) {
    await deployer.deploy(MarketsData);
    await deployer.deploy(MarketFunctions);
    
    let marketDataInstance = await MarketsData.deployed();
    let marketFunctionsInstance = await MarketFunctions.deployed();

    await marketDataInstance.subscribe(marketFunctionsInstance.address);
    await marketFunctionsInstance.initMarketData(marketDataInstance.address);

    console.log(marketFunctionsInstance);
};