// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import '@openzeppelin/contracts/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import '../common/EtherContract.sol';
import '../common/AddressHelper.sol';
import './MarketsData.sol';

contract MarketFunctions is EtherContract, AddressHelper, ERC165 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    event MarketCreated(
        uint256 indexed marketId,
        address indexed owner
    );
    event MarketOwnershipTransferred(
        uint256 indexed marketId,
        address indexed previousOwner,
        address indexed newOwner)
    ;


    MarketsData data;

    function initMarketData(address contractAddress)
    external
    onlyOwner {
        data = MarketsData(contractAddress);
    }


    function createMarket(
        string calldata name,
        string calldata url,
        string calldata tags,
        string calldata description
    )
    external {
        uint256 id = data.createMarket(name, url, tags, description);
        data.changeMarketOwner(id, msg.sender);
        emit MarketCreated(id, msg.sender);
    }


    function transferMarketOwnership(uint256 marketId, address newOwner)
    external
    notZeroAddress(newOwner) {
        requireMarketOwner(marketId, msg.sender);

        data.changeMarketOwner(marketId, newOwner);
    }


    function renounceMarketOwnership(uint256 marketId)
    external {
        requireMarketOwner(marketId, msg.sender);

        data.changeMarketOwner(marketId, address(0));
    }




    function requireMarketOwner(uint256 marketId, address checkAddress)
    public
    view {
        data.requireMarketExists(marketId);
        require(checkAddress == data.getMarketOwner(marketId), "Is not market owner");
    }
}