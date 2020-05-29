const Counters = artifacts.require("@openzeppelin/contracts/drafts/Counters.sol");
const SafeMath = artifacts.require("@openzeppelin/contracts/math/SafeMath.sol");
const SaleReleasePosition = artifacts.require("../library/Release/Sale/SaleReleasePosition.sol");
const SaleReleaseDataList = artifacts.require("../library/Release/Sale/SaleReleaseDataList.sol");
const ListUint256 = artifacts.require("../library/ListUint256.sol");
const MarketPool_Items = artifacts.require("./MarketPool_Items.sol");
const MarketPool_ItemRelease_Sale = artifacts.require("./MarketPool_ItemRelease_Sale.sol");

module.exports = deployer => {
    deployer.link(SafeMath, SaleReleasePosition);
    deployer.deploy(SaleReleasePosition);

    deployer.link(SafeMath, SaleReleaseDataList);
    deployer.link(Counters, SaleReleaseDataList);
    deployer.link(SaleReleasePosition, SaleReleaseDataList);
    deployer.deploy(SaleReleaseDataList);

    deployer.link(SafeMath, ListUint256);
    deployer.link(Counters, ListUint256);
    deployer.deploy(ListUint256);

    deployer.link(SaleReleasePosition, MarketPool_ItemRelease_Sale);
    deployer.link(SaleReleaseDataList, MarketPool_ItemRelease_Sale);
    deployer.link(ListUint256, MarketPool_ItemRelease_Sale);
    deployer.link(MarketPool_Items, MarketPool_ItemRelease_Sale);
    deployer.deploy(MarketPool_ItemRelease_Sale);
};
