pragma solidity >=0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/ownership/Ownable.sol';

/**
 * @author LordOfTheBees
 * @notice Workplace with Market
 */
contract MarketPool is Ownable {
    using SafeMath for uint256;

    event MarketCreated(uint256 indexed marketId);
    event MarketOwnershipTransferred(uint256 indexed marketId, address indexed previousOwner, address indexed newOwner);

    struct Market {
        string name;
    }

    //Список созданных маркетов
    Market[] public markets;

    // ID магазина и их владельцы
    mapping (uint256 => address) marketToOwner;


    /**
     * @notice Create new Market for sender.
     * @param name The name of marketplace
     * @return id of the created market
     */
    function createMarket(string memory name) public returns (uint256) {
        markets.push(Market(name));
        uint256 id = SafeMath.sub(markets.length, 1);
        marketToOwner[id] = msg.sender;
        emit MarketCreated(id);
        return id;
    }

    /**
     * @notice Return all data of market by its id
     */
    function getMarketData(uint256 marketId) public view returns (string memory name) {
        require(marketExist(marketId), "MarketPool: Market does not exist");
        Market storage marketData = markets[marketId];
        return (marketData.name);
    }

    /**
     * @notice Renouncing ownership will leave the contract without an market owner, thereby removing any functionality that is only available to the market owner (e.g. creating new Item Types).
     */
    function renounceMarketOwnership(uint256 marketId) public onlyMarketOwner(marketId) {
        emit MarketOwnershipTransferred(marketId, marketToOwner[marketId], address(0));
        marketToOwner[marketId] = address(0);
    }

    /**
     * @notice Transfers ownership of the ('marketId') to a new account (`newOwner`).
     */
    function transferMarketOwnership(uint256 marketId, address newOwner) public onlyMarketOwner(marketId) notZeroAddress(newOwner) {
        emit MarketOwnershipTransferred(marketId, marketToOwner[marketId], newOwner);
        marketToOwner[marketId] = newOwner;
    }
    
    /**
     * @notice Return addres of market owner
     */
    function getMarketOwner(uint256 marketId) public view returns (address) {
        require(marketExist(marketId), "MarketPool: Market does not exist");
        return marketToOwner[marketId];
    }
    
    /**
     * @notice Chech if it is market owner 
     */
    function isMarketOwner(uint256 marketId) public view returns (bool) {
        require(marketExist(marketId), "MarketPool: Market does not exist");
        return marketToOwner[marketId] == msg.sender;
    }
    
    /**
     * @notice Check if market exist 
     */
    function marketExist(uint256 marketId) public view returns (bool) {
        return markets.length > marketId;
    }


    modifier notZeroAddress(address checkAddress) {
        require(checkAddress != address(0), "MarketPool: CheckAddress is the zero address");
        _;
    }

    modifier onlyMarketOwner(uint256 marketId) {
        require(marketExist(marketId), "MarketPool: Market does not exist");
        require(marketToOwner[marketId] == msg.sender, "MarketPool: Caller is not the owner");
        _;
    }
}
