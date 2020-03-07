pragma solidity >=0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./SaleItem.sol";

library SaleItemList {
    using SafeMath for uint256;
    using SaleItem for SaleItem.Data;

    struct ItemWrapper {
        SaleItem.Data item;
        mapping(bool => uint256) nearbyWrappers; //false - previous item, true - next item
    }

    struct List {
        uint256 rootId;
        uint256 lastId;
        uint256 length;

        uint256 freeIndexesLength;
        uint256 nextWrapperId;

        mapping(uint256 => uint256) freeIndexes;
        mapping(uint256 => ItemWrapper) wrappers;
    }

    /**
     * @dev Creating new List
     * @return (List)
     */
    function newList() internal pure returns (List memory) {
        return List(0, 0, 0, 0, 1);
    }

    /**
     * @dev Return current List length
     * @return (uin256)
     */
    function length(List storage list) public view returns (uint256) {
        return list.length;
    }

    /**
     * @dev Function for loop iterating. O(1).
     * For start looping send zero.
     * When loop finished, function returns zero inner index (this index does not using for items).
     * If you want get Item, call the function {getByInnerIndex}
     * Example:
     uint256 innerIndex = list.next(0);
     while(innerIndex != 0) {
         Item storage item = list.getByInnerIndex(innerIndex);
         //working with item
         innerIndex = list.next(innerIndex);
     }
     * @return (innerIndex:uin256)
     */
    function next(List storage list, uint256 currentInnerIndex)
        public
        view
        returns (uint256)
    {
        if(currentInnerIndex == 0) return list.rootId;
        return list.wrappers[currentInnerIndex].nearbyWrappers[true];
    }

    /**
     * @dev Find and return item by index. O(n).
     * @return (Item storage)
     */
    function get(List storage list, uint256 index)
        public
        view
        returns (SaleItem.Data storage)
    {
        require(index < list.length, "Out of range exception");

        uint256 currentItemId = list.rootId;
        for (uint256 i = 1; i <= index; i = i.add(1)) {
            currentItemId = list.wrappers[currentItemId].nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
        }

        return list.wrappers[currentItemId].item;
    }

    /**
     * @dev Return item by inner index. O(1).
     * @return (Item storage)
     */
    function getByInnerIndex(List storage list, uint256 index)
        public
        view
        returns (SaleItem.Data storage)
    {
        return list.wrappers[index].item;
    }

    /**
     * @dev Return Last added item. O(1).
     * @return (Item storage)
     */
    function last(List storage list) public view returns (SaleItem.Data storage) {
        require(list.lastId != 0, "List does not have elements");
        return list.wrappers[list.lastId].item;
    }

    /**
     * @dev Add new item to list's end. O(1).
     * If you want change item's data, call {get} or {getByInnerIndex}, they returns stored items in this list.
     * Remember, that in this List save only copied item. Therefore, items can be store only in one List
     * @return (normalIndex: uint256; innerIndex: uint256)
     */
    function add(List storage list, SaleItem.Data memory item)
        internal
        returns (uint256 normalIndex, uint256 innerIndex)
    {
        uint256 newItemId = addToInternalArray(list, item);
        if (!rootExist(list)) {
            list.rootId = newItemId;
        } else {
            list.wrappers[list.lastId].nearbyWrappers[true] = newItemId;
            setNearbys(list.wrappers[newItemId], list.lastId, 0);
        }
        uint256 normalId = list.length;
        list.lastId = newItemId;
        list.length = list.length.add(1);

        return (normalId, list.lastId);
    }

    /**
     * @dev Insert new item by index. O(n)
     * If you want change item's data, call {get} or {getByInnerIndex}, they returns stored items in this list.
     * Remember, that in this List save only copied item. Therefore, items can be store only in one List
     * @return (innerIndex: uint256)
     */
    function insert(List storage list, SaleItem.Data memory item, uint256 index)
        internal
        returns (uint256)
    {
        require(index < list.length, "Out of range exception");

        uint256 newItemId = addToInternalArray(list, item);
        if (index == 0) {
            uint256 rootId = list.rootId;
            setNearbys(list.wrappers[newItemId], 0, rootId);
            list.wrappers[rootId].nearbyWrappers[false] = newItemId;

            list.rootId = newItemId;
        } else {
            uint256 currentItemId = list.rootId;
            for (uint256 i = 1; i <= index; i = i.add(1)) {
                currentItemId = list.wrappers[currentItemId]
                    .nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
            }

            ItemWrapper storage nextWrapper = list.wrappers[currentItemId];
            ItemWrapper storage prevWrapper = list.wrappers[nextWrapper
                .nearbyWrappers[false]];
            ItemWrapper storage currentWrapper = list.wrappers[newItemId];

            prevWrapper.nearbyWrappers[true] = newItemId;
            nextWrapper.nearbyWrappers[false] = newItemId;
            setNearbys(
                currentWrapper,
                nextWrapper.nearbyWrappers[false],
                currentItemId
            );
        }

        list.length = list.length.add(1);
        return newItemId;
    }

    /**
     * @dev Find item and remove it. O(n).
     */
    function removeByNormalId(List storage list, uint256 index)
        internal
    {
        require(index < list.length, "Out of range exception");

        uint256 itemIdToRemove = list.rootId;
        for (uint256 i = 1; i <= index; i = i.add(1)) {
            itemIdToRemove = list.wrappers[itemIdToRemove].nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
        }
        uint256 nextId = list.wrappers[itemIdToRemove].nearbyWrappers[true];
        uint256 prevId = list.wrappers[itemIdToRemove].nearbyWrappers[false];

        if (index == list.length - 1) list.lastId = prevId;

        if (index == 0) list.rootId = nextId;
        else {
            list.wrappers[prevId].nearbyWrappers[true] = nextId;
            if (nextId != 0)
                list.wrappers[nextId].nearbyWrappers[false] = prevId;
        }

        list.freeIndexes[list.freeIndexesLength] = itemIdToRemove;
        list.freeIndexesLength = list.freeIndexesLength.add(1);

        list.length = list.length.sub(1);
    }

    /**
     * @dev Remove item by innerIndex. O(1).
     */
    function removeByInnerlId(List storage list, uint256 innerIndex)
        internal
    {
        uint256 nextId = list.wrappers[innerIndex].nearbyWrappers[true];
        uint256 prevId = list.wrappers[innerIndex].nearbyWrappers[false];

        if (innerIndex == list.length - 1) list.lastId = prevId;

        if (innerIndex == 0) list.rootId = nextId;
        else {
            list.wrappers[prevId].nearbyWrappers[true] = nextId;
            if (nextId != 0)
                list.wrappers[nextId].nearbyWrappers[false] = prevId;
        }

        list.freeIndexes[list.freeIndexesLength] = innerIndex;
        list.freeIndexesLength = list.freeIndexesLength.add(1);

        list.length = list.length.sub(1);
    }

    /**
     * @dev Collect elements and Return their as Solidity array
     * @return Item[] memory
     */
    function toArray(List storage list)
        public
        view
        returns (SaleItem.Data[] memory)
    {
        SaleItem.Data[] memory itemsArray = new SaleItem.Data[](list.length);
        if (!rootExist(list)) return itemsArray;

        uint256 currentItemId = list.rootId;
        itemsArray[0] = list.wrappers[currentItemId].item;

        for (uint256 i = 1; i < list.length; i = i.add(1)) {
            currentItemId = list.wrappers[currentItemId].nearbyWrappers[true];
            itemsArray[i] = list.wrappers[currentItemId].item;
        }

        return itemsArray;
    }



    function nextExists(ItemWrapper storage itemWrapper)
        private
        view
        returns (bool)
    {
        return itemWrapper.nearbyWrappers[true] > 0;
    }

    function prevExists(ItemWrapper storage itemWrapper)
        private
        view
        returns (bool)
    {
        return itemWrapper.nearbyWrappers[false] > 0;
    }

    function setNearbys(
        ItemWrapper storage itemWrapper,
        uint256 prev,
        uint256 next
    ) private {
        itemWrapper.nearbyWrappers[true] = next;
        itemWrapper.nearbyWrappers[false] = prev;
    }

    function rootExist(List storage list) private view returns (bool) {
        return list.rootId > 0;
    }

    function addToInternalArray(List storage list, SaleItem.Data memory item)
        private
        returns (uint256)
    {
        uint256 itemId = 0;
        if (list.freeIndexesLength > 0) {
            itemId = list.freeIndexes[list.freeIndexesLength - 1];
            list.freeIndexesLength = list.freeIndexesLength.sub(1);

            list.wrappers[itemId] = ItemWrapper(item);
        } else {
            //require(list.manager.listToNextWrapperId[list.id] == 1, "next index is zero!!!");
            itemId = list.nextWrapperId;
            list.nextWrapperId = list.nextWrapperId.add(1);
            list.wrappers[itemId] = ItemWrapper(item);
        }

        return itemId;
    }
}
