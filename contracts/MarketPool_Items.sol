pragma solidity >=0.6.0;


import "../node_modules/OpenZeppelin/contracts/drafts/Counters.sol";
import "../library/Items.sol";
import "./MarketPool.sol";

contract MarketPool_Items is MarketPool {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Items for Items.ItemType;
    using Items for Items.Item;

    event ItemTypeCreated(uint256 indexed marketId, uint256 indexed itemTypeId);
    event ItemCreated(uint256 indexed marketId, uint256 indexed itemId);
    event ItemOwnershipTransferred(uint256 indexed marketId, uint256 itemId, address indexed previousOwner, address indexed newOwner);
    

    // ID магазина к сущещствующим типам предметов
    mapping (uint256 => Items.ItemType[]) public marketToItemTypes;

    // ID магазина к созданным предметам. Те которые имеют владельцев.
    mapping (uint256 => Items.Item[]) public marketToItems;

    // ID магазина к адресам и к кол-ом предметов которыми они обладают
    mapping (uint256 => mapping (address => Counters.Counter)) marketToUsersToItemsCount;

    // ID магазина к ID предметам к их владельцам
    mapping (uint256 => mapping (uint256 => address)) marketToItemToOwner;


    
    /**
     * @notice Create ItemType for selected Market.
     * @return id of the created ItemType
     */
    function createItemType(
        uint256 marketId,
        string calldata name,
        uint256 totalSuply,
        bool isFinal,
        bool allowSale,
        bool allowAuction,
        bool allowRent,
        bool allowLootbox) 
    external onlyMarketOwner(marketId) returns (uint256) {
        marketToItemTypes[marketId].push(Items.ItemType(
            name,
            totalSuply,
            totalSuply,
            isFinal,
            allowSale,
            allowAuction,
            allowRent,
            allowLootbox));
        uint256 itemTypeId = SafeMath.sub(marketToItemTypes[marketId].length, 1);
        emit ItemTypeCreated(marketId, itemTypeId);
        return itemTypeId;
    }

    /**
     * @notice Can call only owner. Create Item for selected Market and Type. Owner of item will be owner of market 
     * @return id of the created item
     */
    function createItem(uint256 marketId, uint256 typeId) public onlyMarketOwner(marketId) returns (uint256) {
        return _createItem(marketId, typeId, msg.sender);
    }
    
    /**
     * @notice Can call only item owner. Change item owner to ('to')
     */
    function transferItem(address to, uint256 marketId, uint256 itemId) public onlyItemOwner(marketId, itemId) {
        _transferItem(msg.sender, to, marketId, itemId);
    }
    
    
    
    
    
    
    function balanceOfItemsOf(address itemsOwner, uint256 marketId) public view returns (uint256) {
        require(itemsOwner != address(0), "MarketPool_Items: Attempt to check the balance at the zero address");
        require(marketExist(marketId), "MarketPool_Items: Market does not exist");
        
        return marketToUsersToItemsCount[marketId][msg.sender].current();
    }
    
    function getItemOwner(uint256 marketId, uint256 itemId) public view returns(address) {
        require(itemExist(marketId, itemId), "MarketPool_Items: Item Type does not exist");
        
        return marketToItemToOwner[marketId][itemId];
    }
    
    function isItemOwner(uint256 marketId, uint256 itemId) public view returns (bool) {
        require(itemExist(marketId, itemId), "MarketPool_Items: Item does not exist");
        
        return marketToItemToOwner[marketId][itemId] == msg.sender;
    }
    
    function itemTypeExist(uint256 marketId, uint256 typeId) public view returns (bool) {
        return marketExist(marketId) && marketToItemTypes[marketId].length > typeId;
    }
    
    function itemExist(uint256 marketId,uint256 itemId) public view returns (bool) {
        return marketExist(marketId) && marketToItems[marketId].length > itemId;
    }
    
    
    
    
    
    
    
    function _transferItem(address itemOwner, address to, uint256 marketId, uint256 itemId) internal {
        require(getItemOwner(marketId, itemId) == itemOwner, "MarketPool_Items: itemOwner is not the real item owner");
        require(to != address(0), "MarketPool_Items: Attempt to establish a new owner as a zero address");
        marketToUsersToItemsCount[marketId][itemOwner].decrement();
        marketToUsersToItemsCount[marketId][to].increment();
        marketToItemToOwner[marketId][itemId] = to;
        
        emit ItemOwnershipTransferred(marketId, itemId, itemOwner, to);
    }
    
    
    /**
     * @dev Create Item for selected Market and Type. Owner of item will be ('itemOwner')
     * @return id of the created item
     */
    function _createItem(uint256 marketId, uint256 typeId, address newItemOwner) internal returns (uint256) {
        require(itemTypeExist(marketId, typeId), "MarketPool_Items: Item Type does not exist");
        require(newItemOwner != address(0), "MarketPool_Items: Item Owner is the zero address");
        
        Items.ItemType storage itemType = marketToItemTypes[marketId][typeId];
        require(itemType.itemsOver(), "MarketPool_Items: Items of this type are over");

        marketToItems[marketId].push(Items.Item(typeId));
        uint256 itemId = SafeMath.sub(marketToItems[marketId].length, 1);
        marketToUsersToItemsCount[marketId][newItemOwner].increment();
        marketToItemToOwner[marketId][itemId] = newItemOwner;
        
        itemType.recordItemCreated();

        emit ItemCreated(marketId, itemId);
        return itemId;
    }
    
    
    
    modifier onlyItemOwner(uint256 marketId, uint256 itemId) {
        require(itemExist(marketId, itemId), "MarketPool_Items: Item does not exist");
        require(marketToItemToOwner[marketId][itemId] == msg.sender, "MarketPool_Items: It is not owner");
        _;
    }
}