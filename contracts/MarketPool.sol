pragma solidity >=0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/ownership/Ownable.sol';
import "@openzeppelin/contracts/drafts/Counters.sol";

/**
 * @author LordOfTheBees
 * @notice Workplace with Market
 */
contract MarketPool is Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    event MarketCreated(uint256 indexed marketId, address indexed owner);
    event MarketOwnershipTransferred(uint256 indexed marketId, address indexed previousOwner, address indexed newOwner);

    struct Market {
        string name;
    }

    //Список созданных маркетов
    Market[] public markets;

    // ID магазина и их владельцы
    mapping (uint256 => address) marketToOwner;

    mapping (address => Counters.Counter) addressToMarketCount;



    receive() external payable {
    }
    
    fallback() external payable {
    }

    function withdraw() external onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }




    /**
     * @notice Create new Market for sender.
     * @param name The name of marketplace
     * @return id of the created market
     */
    function createMarket(string memory name) public returns (uint256) {
        markets.push(Market(name));
        uint256 id = markets.length.sub(1);
        marketToOwner[id] = msg.sender;
        addressToMarketCount[msg.sender].increment();
        emit MarketCreated(id, msg.sender);
        return id;
    }

    /**
     * @notice Return all data of market by its id
     */
    function getMarketData(uint256 marketId) public view onlyMarketExists(marketId) returns (string memory name) {
        Market storage marketData = markets[marketId];
        return (marketData.name);
    }

    /**
     * @notice Renouncing ownership will leave the contract without an market owner, thereby removing any functionality that is only available to the market owner (e.g. creating new Item Types).
     */
    function renounceMarketOwnership(uint256 marketId) public onlyMarketOwner(marketId) {
        emit MarketOwnershipTransferred(marketId, marketToOwner[marketId], address(0));
        addressToMarketCount[msg.sender].decrement();
        marketToOwner[marketId] = address(0);
    }

    /**
     * @notice Transfers ownership of the ('marketId') to a new account (`newOwner`).
     */
    function transferMarketOwnership(uint256 marketId, address newOwner) public onlyMarketOwner(marketId) notZeroAddress(newOwner) {
        emit MarketOwnershipTransferred(marketId, marketToOwner[marketId], newOwner);
        marketToOwner[marketId] = newOwner;
        addressToMarketCount[msg.sender].decrement();
        addressToMarketCount[newOwner].increment();
    }
    
    /**
     * @notice Return addres of market owner
     */
    function getMarketOwner(uint256 marketId) public view onlyMarketExists(marketId) returns (address) {
        return marketToOwner[marketId];
    }

    function getMarketCounts(address owner) public view returns (uint256) {
        return addressToMarketCount[owner].current();
    }
    
    /**
     * @notice Chech if it is market owner 
     */
    function isMarketOwner(uint256 marketId) public view onlyMarketExists(marketId) returns (bool) {
        return marketToOwner[marketId] == msg.sender;
    }
    
    /**
     * @notice Check if market exist 
     */
    function marketExist(uint256 marketId) public view returns (bool) {
        return markets.length > marketId;
    }


    modifier notZeroAddress(address checkAddress) {
        require(checkAddress != address(0), "CheckAddress is the zero address");
        _;
    }

    modifier onlyMarketExists(uint256 marketId) {
        require(marketExist(marketId), "MarketPool: Market does not exist");
        _;
    }

    modifier onlyMarketOwner(uint256 marketId) {
        require(marketExist(marketId), "Market does not exist");
        require(marketToOwner[marketId] == msg.sender, "Caller is not the owner");
        _;
    }
}
