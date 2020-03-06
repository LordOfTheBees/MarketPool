const Counters = artifacts.require("@openzeppelin/contracts/drafts/Counters.sol");
const SafeMath = artifacts.require("@openzeppelin/contracts/math/SafeMath.sol");
const Item = artifacts.require("../library/Items.sol");
const MarketPool = artifacts.require("./MarketPool.sol");
const MarketPool_Items = artifacts.require("./MarketPool_Items.sol");

module.exports = deployer => {
    deployer.deploy(Counters);
    
    deployer.link(SafeMath, Item);
    deployer.deploy(Item);

    deployer.link(Item, MarketPool_Items);
    deployer.link(Counters, MarketPool_Items);
    deployer.link(MarketPool, MarketPool_Items);

    deployer.deploy(MarketPool_Items);
};