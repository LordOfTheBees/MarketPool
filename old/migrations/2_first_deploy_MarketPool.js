const Counters = artifacts.require("@openzeppelin/contracts/drafts/Counters.sol");
const SafeMath = artifacts.require("@openzeppelin/contracts/math/SafeMath.sol");
const MarketPool = artifacts.require("./MarketPool.sol");

module.exports = function(deployer) {
    deployer.deploy(Counters);
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, MarketPool);
    deployer.link(Counters, MarketPool);

    deployer.deploy(MarketPool);
};