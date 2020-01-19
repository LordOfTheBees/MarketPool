pragma solidity >=0.5.0;


import "../node_modules/OpenZeppelin/contracts/drafts/Counters.sol";
import "../library/Items.sol";
import "./StorePool.sol";

contract StorePool_Items is StorePool {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Items for Items.ItemType;
    using Items for Items.Item;

    event ItemTypeCreated(uint256 indexed storeId, uint256 indexed itemTypeId);
    event ItemCreated(uint256 indexed storeId, uint256 indexed itemId);
    event ItemOwnershipTransferred(uint256 indexed storeId, uint256 itemId, address indexed previousOwner, address indexed newOwner);
    

    // ID магазина к сущещствующим типам предметов
    mapping (uint256 => Items.ItemType[]) public storeToItemTypes;

    // ID магазина к созданным предметам. Те которые имеют владельцев.
    mapping (uint256 => Items.Item[]) public storeToItems;

    // ID магазина к адресам и к кол-ом предметов которыми они обладают
    mapping (uint256 => mapping (address => Counters.Counter)) storeToUsersToItemsCount;

    // ID магазина к ID предметам к их владельцам
    mapping (uint256 => mapping (uint256 => address)) storeToItemToOwner;


    
    /**
     * @notice Create ItemType for selected Store.
     * @return id of the created ItemType
     */
    function createItemType(
        uint256 storeId,
        string calldata name,
        uint256 totalSuply,
        bool isFinal,
        bool allowSale,
        bool allowAuction,
        bool allowRent,
        bool allowLootbox) 
    external 
    onlyStoreOwner(storeId) 
    returns (uint256){
        storeToItemTypes[storeId].push(Items.ItemType(
            name,
            totalSuply,
            totalSuply,
            isFinal,
            allowSale,
            allowAuction,
            allowRent,
            allowLootbox));
        uint256 itemTypeId = SafeMath.sub(storeToItemTypes[storeId].length, 1);
        emit ItemTypeCreated(storeId, itemTypeId);
        return itemTypeId;
    }

    /**
     * @notice Can call only owner. Create Item for selected Store and Type. Owner of item will be owner of store 
     * @return id of the created item
     */
    function createItem(
        uint256 storeId,
        uint256 typeId
    ) 
    public
    onlyStoreOwner(storeId)
    returns (uint256) {
        return _createItem(storeId, typeId, msg.sender);
    }
    
    /**
     * @notice Can call only item owner. Change item owner to ('to')
     */
    function transferItem(address to, uint256 storeId, uint256 itemId)
    public
    onlyItemOwner(storeId, itemId) {
        _transferItem(msg.sender, to, storeId, itemId);
    }
    
    
    
    function balanceOfItemsOf(
        address itemsOwner,
        uint256 storeId)
    public
    view
    returns (uint256) {
        require(itemsOwner != address(0), "StorePool_Items: StorePool_Items: Attempt to check the balance at the zero address");
        require(stores.length > storeId, "StorePool_Items: Store does not exist");
        
        return storeToUsersToItemsCount[storeId][msg.sender].current();
    }
    
    function getItemOwner(
        uint256 storeId, 
        uint256 itemId)
    public
    view
    returns(address) {
        require(stores.length > storeId, "StorePool_Items: Store does not exist");
        require(storeToItems[storeId].length > itemId, "StorePool_Items: Item Type does not exist");
        
        return storeToItemToOwner[storeId][itemId];
    }
    
    function isItemOwner(uint256 storeId, uint256 itemId)
    public 
    view
    returns (bool) {
        require(stores.length > storeId, "StorePool_Items: Store does not exist");
        require(storeToItems[storeId].length > itemId, "StorePool_Items: Item does not exist");
        
        return storeToItemToOwner[storeId][itemId] == msg.sender;
    }
    
    
    
    function _transferItem(
        address itemOwner,
        address to,
        uint256 storeId,
        uint256 itemId)
    internal {
        require(getItemOwner(storeId, itemId) == itemOwner, "StorePool_Items: itemOwner is not the real item owner");
        require(to != address(0), "StorePool_Items: Attempt to establish a new owner as a zero address");
        storeToUsersToItemsCount[storeId][itemOwner].decrement();
        storeToUsersToItemsCount[storeId][to].increment();
        storeToItemToOwner[storeId][itemId] = to;
        
        emit ItemOwnershipTransferred(storeId, itemId, itemOwner, to);
    }
    
    
    /**
     * @dev Create Item for selected Store and Type. Owner of item will be ('itemOwner')
     * @return id of the created item
     */
    function _createItem(
        uint256 storeId,
        uint256 typeId,
        address newItemOwner
    )
    internal
    returns (uint256) {
        require(stores.length > storeId, "StorePool_Items: Store does not exist");
        require(storeToItemTypes[storeId].length > typeId, "StorePool_Items: Item Type does not exist");
        require(newItemOwner != address(0), "StorePool_Items: Item Owner is the zero address");
        
        Items.ItemType storage itemType = storeToItemTypes[storeId][typeId];
        require(itemType.itemsOver(), "StorePool_Items: Items of this type are over");

        storeToItems[storeId].push(Items.Item(typeId));
        uint256 itemId = SafeMath.sub(storeToItems[storeId].length, 1);
        storeToUsersToItemsCount[storeId][newItemOwner].increment();
        storeToItemToOwner[storeId][itemId] = newItemOwner;
        
        itemType.recordItemCreated();

        emit ItemCreated(storeId, itemId);
        return itemId;
    }
    
    
    
    modifier onlyItemOwner(uint256 storeId, uint256 itemId) {
        require(stores.length > storeId, "StorePool_Items: Store does not exist");
        require(storeToItems[storeId].length > itemId, "StorePool_Items: Item does not exist");
        require(storeToItemToOwner[storeId][itemId] == msg.sender, "StorePool_Items: It is not owner");
        _;
    }
}