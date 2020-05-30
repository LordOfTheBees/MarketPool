const MarketsData = artifacts.require("./MarketsData.sol");

module.exports = function(deployer) {
    deployer.deploy(MarketsData);
};