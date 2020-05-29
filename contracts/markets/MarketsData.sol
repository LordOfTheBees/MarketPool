pragma solidity >=0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/ownership/Ownable.sol';
import "@openzeppelin/contracts/drafts/Counters.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import '../ContractSubscriber.sol';

contract MarketsData is ContractSubscriber, ERC165 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    event MarketCreated(uint256 indexed marketId, address indexed owner);
    event MarketOwnershipTransferred(uint256 indexed marketId, address indexed from, address indexed to);

    struct Market {
        string name;
        string url;
        string tags;
        string description;
    }

    Market[] public markets;

    //ID магазина к владельцу
    mapping (uint256 => address) marketToOwner;

    //Аддресс к кол-ву магазинов
    mapping (address => Counters.Counter) addressToMarketsCount;

    receive() external payable { }
    fallback() external payable { }
    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enought");
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    function createMarket(
        address owner,
        string calldata name,
        string calldata url,
        string calldata tags,
        string calldata description) external onlySubscriber 
    {
        
    }
}