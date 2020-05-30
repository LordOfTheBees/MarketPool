// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import '@openzeppelin/contracts/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import '../library/Markets.sol';
import '../common/ContractSubscriber.sol';
import '../common/EtherContract.sol';

contract MarketsData is ContractSubscriber, EtherContract, ERC165 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    //Массив магазинов
    Markets.Market[] private markets;

    //ID магазина к владельцу
    mapping (uint256 => address) private marketToOwner;

    //Аддресс к кол-ву магазинов
    mapping (address => Counters.Counter) private addressToMarketsCount;

    /**
     * @notice Create new market and add to array
     */
    function createMarket(
        string calldata name,
        string calldata url,
        string calldata tags,
        string calldata description
    )
    external
    onlySubscriber
    returns (uint256) {
        markets.push(Markets.Market(name, url, tags, description));
        return markets.length.sub(1);
    }

    /**
     * @notice Change market owner and count of markets. If in market already has owner, it will be changed
     */
    function changeMarketOwner(uint256 marketId, address marketOwner)
    external
    onlySubscriber {
        if (marketToOwner[marketId] != address(0)) {
            addressToMarketsCount[marketToOwner[marketId]].decrement();
        }
        marketToOwner[marketId] = marketOwner;
        addressToMarketsCount[marketOwner].increment();
    }

    /**
     * @notice Check market exists by id
     */
    function marketExists(uint256 marketId)
    public
    view
    returns (bool) {
        return markets.length > marketId;
    }


    /**
     * @notice Get market data
     */
    function getMarket(uint256 marketId)
    external
    view
    returns (
        string memory name,
        string memory url,
        string memory tags,
        string memory description
    ) {
        Markets.Market memory market = markets[marketId];
        return (
            market.name,
            market.url,
            market.tags,
            market.description
        );
    }

    /**
     * @notice Get market owner
     */
    function getMarketOwner(uint256 marketId)
    external
    view
    returns (address) {
        return marketToOwner[marketId];
    }

    /**
     * @notice Get markets count for address
     */
    function getMarketsCountFor(address marketOwner)
    external
    view
    returns (uint256) {
        return addressToMarketsCount[marketOwner].current();
    }

    /**
     * @notice Get markets count
     */
    function getMarketsCount()
    external
    view
    returns (uint256) {
        return markets.length;
    }



    function requireMarketExists(uint256 marketId)
    public
    view {
        require(marketExists(marketId), "Market does not exists");
    }
}