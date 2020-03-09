const Counters = artifacts.require("@openzeppelin/contracts/drafts/Counters.sol");
const SafeMath = artifacts.require("@openzeppelin/contracts/math/SafeMath.sol");
const Sale = artifacts.require("../library/Release/Sale/Sale.sol");
const SaleDataList = artifacts.require("../library/Release/Sale/SaleDataList.sol");
const MarketPool_Items = artifacts.require("./MarketPool_Items.sol");
const MarketPool_ItemRelease_Sale = artifacts.require("./MarketPool_ItemRelease_Sale.sol");

module.exports = deployer => {
    deployer.link(SafeMath, Sale);
    deployer.deploy(Sale);

    deployer.link(SafeMath, SaleDataList);
    deployer.link(Counters, SaleDataList);
    deployer.link(Sale, SaleDataList);
    deployer.deploy(SaleDataList);

    deployer.link(Sale, MarketPool_ItemRelease_Sale);
    deployer.link(SaleDataList, MarketPool_ItemRelease_Sale);
    deployer.link(MarketPool_Items, MarketPool_ItemRelease_Sale);
    deployer.deploy(MarketPool_ItemRelease_Sale);
};
