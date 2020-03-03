const SafeMath = artifacts.require("openzeppelin/contracts/math/SafeMath.sol");
const MarketPool = artifacts.require("./MarketPool.sol");

module.exports = function(deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, MarketPool);

    deployer.deploy(MarketPool);
};