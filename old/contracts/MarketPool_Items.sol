pragma solidity >=0.6.0;

import "@openzeppelin/contracts/drafts/Counters.sol";
import "../library/Items.sol";
import "./MarketPool.sol";

contract MarketPool_Items is MarketPool {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Items for Items.ItemType;
    using Items for Items.Item;

    event ItemTypeCreated(uint256 indexed marketId, uint256 indexed itemTypeId);
    event ItemCreated(
        uint256 indexed marketId,
        uint256 indexed itemTypeId,
        uint256 indexed itemId
    );
    event ItemOwnershipTransferred(
        uint256 indexed marketId,
        uint256 itemId,
        address indexed previousOwner,
        address indexed newOwner
    );

    // ID магазина к сущещствующим типам предметов
    mapping(uint256 => Items.ItemType[]) public marketToItemTypes;

    // ID магазина к созданным предметам. Те которые имеют владельцев.
    mapping(uint256 => Items.Item[]) public marketToItems;

    // ID магазина к адресам и к кол-ом предметов которыми они обладают
    mapping(uint256 => mapping(address => Counters.Counter)) public marketToUsersToItemsCount;

    // ID магазина к ID предметам к их владельцам
    mapping(uint256 => mapping(uint256 => address)) public marketToItemToOwner;

    /**
     * @notice Create ItemType for selected Market.
     * @return id of the created ItemType
     */
    function createItemType(
        uint256 marketId,
        string calldata name,
        uint256 totalSupply,
        bool allowSale,
        bool allowAuction,
        bool allowRent,
        bool allowLootbox
    ) external onlyMarketOwner(marketId) returns (uint256) {
        marketToItemTypes[marketId].push(
            Items.ItemType(
                name,
                totalSupply,
                totalSupply,
                totalSupply > 0,
                allowSale,
                allowAuction,
                allowRent,
                allowLootbox
            )
        );
        uint256 itemTypeId = marketToItemTypes[marketId].length.sub(1);
        emit ItemTypeCreated(marketId, itemTypeId);
        return itemTypeId;
    }

    /**
     * @notice Can call only owner. Create Item for selected Market and Type. Owner of item will be owner of market
     * @return id of the created item
     */
    function createItem(uint256 marketId, uint256 typeId)
        public
        onlyMarketOwner(marketId)
        onlyItemTypeExist(marketId, typeId)
        returns (uint256)
    {
        return _createItem(marketId, typeId, msg.sender);
    }

    /**
     * @notice Can call only item owner. Change item owner to ('to')
     */
    function transferItemOwnership(uint256 marketId, uint256 itemId, address to)
        public
        onlyItemOwner(marketId, itemId)
        notZeroAddress(to)
    {
        _transferItemOwnership(marketId, itemId, msg.sender, to);
    }




    /**
     * @notice Return data about item type
     */
    function getItemTypeData(uint256 marketId, uint256 typeId)
        public
        view
        onlyItemTypeExist(marketId, typeId)
        returns (
            string memory name,
            uint256 remainingSupply,
            uint256 totalSupply,
            bool isFinal,
            bool allowSale,
            bool allowAuction,
            bool allowRent,
            bool allowLootbox
        )
    {
        Items.ItemType memory itemType = marketToItemTypes[marketId][typeId];
        return (
            itemType.name,
            itemType.remainingSupply,
            itemType.totalSupply,
            itemType.isFinal,
            itemType.allowSale,
            itemType.allowAuction,
            itemType.allowRent,
            itemType.allowLootbox
        );
    }

    /**
     * @notice Return data about item
     */
    function getItemData(uint256 marketId, uint256 itemId)
        public
        view
        onlyItemExist(marketId, itemId)
        returns (uint256 itemTypeId)
    {
        Items.Item memory item = marketToItems[marketId][itemId];
        return (item.typeId);
    }

    function balanceOfItems(uint256 marketId, address itemsOwner)
        public
        view
        returns (uint256)
    {
        require(itemsOwner != address(0), "MarketPool_Items: Attempt to check the balance at the zero address");
        require(marketExist(marketId), "MarketPool_Items: Market does not exist");

        return marketToUsersToItemsCount[marketId][itemsOwner].current();
    }

    function getItemOwner(uint256 marketId, uint256 itemId)
        public
        view
        returns (address)
    {
        require(itemExist(marketId, itemId), "MarketPool_Items: Item Type does not exist");

        return marketToItemToOwner[marketId][itemId];
    }

    function isItemOwner(uint256 marketId, uint256 itemId)
        public
        view
        returns (bool)
    {
        require(itemExist(marketId, itemId), "MarketPool_Items: Item does not exist");

        return marketToItemToOwner[marketId][itemId] == msg.sender;
    }

    function itemTypeExist(uint256 marketId, uint256 typeId)
        public
        view
        returns (bool)
    {
        return
            marketExist(marketId) &&
            marketToItemTypes[marketId].length > typeId;
    }

    function itemExist(uint256 marketId, uint256 itemId)
        public
        view
        returns (bool)
    {
        return marketExist(marketId) && marketToItems[marketId].length > itemId;
    }




    function _transferItemOwnership(
        uint256 marketId,
        uint256 itemId,
        address from,
        address to
    ) internal notZeroAddress(to) {
        require(from != to, "MarketPool_Items: 'from' address equal 'to' address");
        require(itemExist(marketId, itemId), "MarketPool_Items: Item does not exist");
        require(marketToItemToOwner[marketId][itemId] == from, "MarketPool_Items: It is not owner");

        marketToUsersToItemsCount[marketId][from].decrement();
        marketToUsersToItemsCount[marketId][to].increment();
        marketToItemToOwner[marketId][itemId] = to;

        emit ItemOwnershipTransferred(marketId, itemId, from, to);
    }

    /**
     * @dev Create Item for selected Market and Type. Owner of item will be ('itemOwner')
     * @return id of the created item
     */
    function _createItem(uint256 marketId, uint256 typeId, address newItemOwner)
        internal
        returns (uint256)
    {
        Items.ItemType storage itemType = marketToItemTypes[marketId][typeId];
        require(
            itemType.creatingPossible(),
            "MarketPool_Items: cannot create an item of this type"
        );

        marketToItems[marketId].push(Items.Item(typeId));
        uint256 itemId = marketToItems[marketId].length.sub(1);
        marketToUsersToItemsCount[marketId][newItemOwner].increment();
        marketToItemToOwner[marketId][itemId] = newItemOwner;

        itemType.recordItemCreated();

        emit ItemCreated(marketId, typeId, itemId);
        return itemId;
    }





    modifier onlyItemTypeExist(uint256 marketId, uint256 itemTypeId) {
        require(
            itemTypeExist(marketId, itemTypeId),
            "MarketPool_Items: Item Type does not exist"
        );
        _;
    }

    modifier onlyItemExist(uint256 marketId, uint256 itemId) {
        require(
            itemExist(marketId, itemId),
            "MarketPool_Items: Item does not exist"
        );
        _;
    }

    modifier onlyItemOwner(uint256 marketId, uint256 itemId) {
        require(
            itemExist(marketId, itemId),
            "MarketPool_Items: Item does not exist"
        );
        require(
            marketToItemToOwner[marketId][itemId] == msg.sender,
            "MarketPool_Items: It is not owner"
        );
        _;
    }
}
