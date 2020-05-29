pragma solidity >=0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

library ListUint256 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    struct ItemWrapper {
        uint256 item;
        mapping(bool => uint256) nearbyWrappers; //false - previous item, true - next item
    }

    struct List {
        uint256 rootId;
        uint256 lastId;

        uint256 freeIndexesLength;
        uint256 nextWrapperId;

        Counters.Counter length;

        mapping(uint256 => uint256) freeIndexes;
        mapping(uint256 => ItemWrapper) wrappers;
    }

    /**
     * @dev Creating new List
     * @return List
     */
    function newList() internal pure returns (List memory) {
        return List(0, 0, 0, 1, Counters.Counter(0));
    }


    /**
     * @dev Add new item to list's end. O(1).
     * If you want change item's data, call {get} or {getByInnerIndex}, they returns stored items in this list.
     * Remember, that in this List save only copied item. Therefore, items can be store only in one List
     * @return normalIndex and innerIndex
     */
    function add(List storage list, uint256 item)
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
        uint256 normalId = list.length.current();
        list.lastId = newItemId;
        list.length.increment();

        return (normalId, newItemId);
    }

    /**
     * @dev Insert new item by index. O(n)
     * If you want change item's data, call {get} or {getByInnerIndex}, they returns stored items in this list.
     * Remember, that in this List save only copied item. Therefore, items can be store only in one List
     * @return innerIndex returned
     */
    function insert(List storage list, uint256 item, uint256 index)
        internal
        returns (uint256)
    {
        require(index < list.length.current(), "Out of range exception");

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

        list.length.increment();
        return newItemId;
    }

    /**
     * @dev Replace item by index. O(n)
     * If you want change item's data, call {get} or {getByInnerIndex}, they returns stored items in this list.
     * Remember, that in this List save only copied item. Therefore, items can be store only in one List
     * @return (innerIndex: uint256)
     */
    function replaceByNormalId(List storage list, uint256 index, uint256 item)
        internal
        returns (uint256)
    {
        require(index < list.length.current(), "Out of range exception");

        uint256 itemIdToReplace = list.rootId;
        for (uint256 i = 1; i <= index; i = SafeMath.add(i, 1)) {
            itemIdToReplace = list.wrappers[itemIdToReplace].nearbyWrappers[true];
        }
        list.wrappers[itemIdToReplace].item = item;

        return itemIdToReplace;
    }

    /**
     * @dev Replace item by inner index. O(1)
     * If you want change item's data, call {get} or {getByInnerIndex}, they returns stored items in this list.
     * Remember, that in this List save only copied item. Therefore, items can be store only in one List
     */
    function replaceByInnerlId(List storage list, uint256 index, uint256 item)
        internal
    {
        list.wrappers[index].item = item;
    }

    /**
     * @dev Find item and remove it. O(n).
     */
    function removeByNormalId(List storage list, uint256 index)
        internal
    {
        require(index < list.length.current(), "Out of range exception");

        uint256 itemIdToRemove = list.rootId;
        for (uint256 i = 1; i <= index; i = i.add(1)) {
            itemIdToRemove = list.wrappers[itemIdToRemove].nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
        }
        uint256 nextId = list.wrappers[itemIdToRemove].nearbyWrappers[true];
        uint256 prevId = list.wrappers[itemIdToRemove].nearbyWrappers[false];

        if (itemIdToRemove == list.lastId) list.lastId = prevId;
        if (itemIdToRemove == list.rootId) list.rootId = nextId;
        
        else {
            list.wrappers[prevId].nearbyWrappers[true] = nextId;
            if (nextId != 0)
                list.wrappers[nextId].nearbyWrappers[false] = prevId;
        }

        list.freeIndexes[list.freeIndexesLength] = itemIdToRemove;
        list.freeIndexesLength = list.freeIndexesLength.add(1);
        setNearbys(list.wrappers[itemIdToRemove], 0, 0); //удаляем зависимости для дальнейшего определения  существования

        list.length.decrement();
    }

    /**
     * @dev Remove item by innerIndex. O(1).
     */
    function removeByInnerlId(List storage list, uint256 innerIndex)
        internal
    {
        uint256 nextId = list.wrappers[innerIndex].nearbyWrappers[true];
        uint256 prevId = list.wrappers[innerIndex].nearbyWrappers[false];

        if (innerIndex == list.lastId) list.lastId = prevId;
        if (innerIndex == list.rootId) list.rootId = nextId;

        else {
            list.wrappers[prevId].nearbyWrappers[true] = nextId;
            if (nextId != 0)
                list.wrappers[nextId].nearbyWrappers[false] = prevId;
        }

        list.freeIndexes[list.freeIndexesLength] = innerIndex;
        list.freeIndexesLength = list.freeIndexesLength.add(1);
        setNearbys(list.wrappers[innerIndex], 0, 0); //удаляем зависимости для дальнейшего определения  существования

        list.length.decrement();
    }

        /**
     * @dev Return current List length
     * @return uin256
     */
    function getLength(List storage list) public view returns (uint256) {
        return list.length.current();
    }

    /**
     * @dev Function for loop iterating. O(1).
     * For start looping send zero.
     * When loop finished, function returns zero inner index (this index does not using for items).
     * If you want get Item, call the function {getByInnerIndex}
     * Example:
     uint256 innerIndex = list.iterate(0);
     while(innerIndex != 0) {
         Item storage item = list.getByInnerIndex(innerIndex);
         //working with item
         innerIndex = list.iterate(innerIndex);
     }
     * @return innerIndex returned
     */
    function iterate(List storage list, uint256 currentInnerIndex)
        public
        view
        returns (uint256)
    {
        if(currentInnerIndex == 0) return list.rootId;
        return list.wrappers[currentInnerIndex].nearbyWrappers[true];
    }

    /**
     * @dev Find and return item by index. O(n).
     */
    function get(List storage list, uint256 index)
        public
        view
        returns (uint256 item, uint256 innerId)
    {
        require(index < list.length.current(), "Out of range exception");

        uint256 currentItemId = list.rootId;
        for (uint256 i = 1; i <= index; i = i.add(1)) {
            currentItemId = list.wrappers[currentItemId].nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
        }

        return (list.wrappers[currentItemId].item, currentItemId);
    }

    /**
     * @dev Return item by inner index. O(1).
     * @return Item storage
     */
    function getByInnerIndex(List storage list, uint256 index)
        public
        view
        returns (uint256)
    {
        return list.wrappers[index].item;
    }

    /**
     * @dev Return Last added item. O(1).
     * @return Item storage
     */
    function last(List storage list)
        public
        view
        returns (uint256)
    {
        require(list.lastId != 0, "List does not have elements");
        return list.wrappers[list.lastId].item;
    }

    function existsById(List storage list, uint256 id)
        public
        view
        returns (bool)
    {
        return id < list.length.current();
    }

    function existsByInnerId(List storage list, uint256 innerId)
        public
        view
        returns (bool)
    {
        return list.rootId == innerId || list.wrappers[innerId].nearbyWrappers[true] != 0 || list.wrappers[innerId].nearbyWrappers[false] != 0;
    }

    /**
     * @dev Collect elements and Return their as Solidity array
     * @return Item[] memory
     */
    function toArray(List storage list)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory itemsArray = new uint256[](list.length.current());
        if (!rootExist(list)) return itemsArray;

        uint256 currentItemId = list.rootId;
        itemsArray[0] = list.wrappers[currentItemId].item;

        for (uint256 i = 1; i < list.length.current(); i = i.add(1)) {
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
        uint256 next)
        private
    {
        itemWrapper.nearbyWrappers[true] = next;
        itemWrapper.nearbyWrappers[false] = prev;
    }

    function rootExist(List storage list) private view returns (bool) {
        return list.rootId > 0;
    }

    function addToInternalArray(List storage list, uint256 item)
        private
        returns (uint256)
    {
        initIfNeed(list);

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

    function initIfNeed(List storage list)
        private
    {
        if(list.nextWrapperId == 0)
        {
            require(list.rootId == 0 &&
                list.freeIndexesLength == 0 &&
                list.lastId == 0 &&
                list.length.current() == 0, "Internal error with List Implementation");
            list.nextWrapperId = 1;
        }
    }
}
