pragma solidity >=0.5.0;

import "./StorePool.sol";

contract StorePool_Items is StorePool {
    using SafeMath for uint256;

    event ItemTypeCreated(uint256 indexed storeId, uint256 indexed itemTypeId);
    event ItemCreated(uint256 indexed storeId, uint256 indexed itemId);
    event ItemOwnershipTransferred(uint256 indexed storeId, uint256 itemId, address indexed previousOwner, address indexed newOwner);

    struct Item {
        uint256 typeId;
    }

    struct ItemType {
        string name;

        uint256 remainingSuply;
        uint256 totalSuply;

        // Конечное ли количество элементов данного типа
        bool isFinal;

        bool allowSale;
        bool allowAuction;
        bool allowRent;
        bool allowLootbox;
    }

    // ID магазина к сущещствующим типам предметов
    mapping (uint256 => ItemType[]) public storeToItemTypes;

    // ID магазина к созданным предметам. Те которые имеют владельцев.
    mapping (uint256 => Item[]) public storeToItems;

    // ID магазина к адресам и к кол-ом предметов которыми они обладают
    mapping (uint256 => mapping (address => uint256)) storeToUsersToItemsCount;

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
        storeToItemTypes[storeId].push(ItemType(
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
    function transferItemOwnership(uint256 storeId, uint256 itemId, address to)
    public
    onlyItemOwner(storeId, itemId) {
        require(to != address(0), "TO is zero address");
        emit ItemOwnershipTransferred(storeId, itemId, storeToItemToOwner[storeId][itemId], to);
        storeToItemToOwner[storeId][itemId] = to;
    }
    
    function isItemOwner(uint256 storeId, uint256 itemId)
    public 
    view
    returns (bool) {
        return storeToItemToOwner[storeId][itemId] == msg.sender;
    }
    
    
    
    /**
     * @dev Create Item for selected Store and Type. Owner of item will be ('itemOwner')
     * @return id of the created item
     */
    function _createItem(
        uint256 storeId,
        uint256 typeId,
        address itemOwner
    )
    internal
    returns (uint256) {
        require(stores.length > storeId, "Store does not exist");
        require(storeToItemTypes[storeId].length > typeId, "Item Type does not exist");
        require(itemOwner != address(0), "Item Owner is the zero address");
        
        ItemType storage itemType = storeToItemTypes[storeId][typeId];
        require(!itemType.isFinal || itemType.remainingSuply > 0, "Items of this type are over");

        storeToItems[storeId].push(Item(typeId));
        uint256 itemId = SafeMath.sub(storeToItems[storeId].length, 1);
        storeToUsersToItemsCount[storeId][itemOwner] = SafeMath.add(storeToUsersToItemsCount[storeId][itemOwner], 1);
        storeToItemToOwner[storeId][itemId] = itemOwner;
        
        if(itemType.isFinal) itemType.remainingSuply = SafeMath.sub(itemType.remainingSuply, 1);

        emit ItemCreated(storeId, itemId);
        return itemId;
    }
    
    
    
    modifier onlyItemOwner(uint256 storeId, uint256 itemId) {
        require(stores.length > storeId, "Store does not exist");
        require(storeToItems[storeId].length > itemId, "Item does not exist");
        _;
    }
}