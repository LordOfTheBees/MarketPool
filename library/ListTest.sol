pragma solidity >=0.5.0;

import "../node_modules/OpenZeppelin/contracts/math/SafeMath.sol";

library ListTest {
    using SafeMath for uint256;

    struct TestItem {
        uint256 data;
    }
    
    struct ItemWrapper{
        TestItem item;
        
        mapping(bool => uint256) nearbyWrappers;//false - previous item, true - next item
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
    
    function createList() internal pure returns(List memory) {
        return List(0, 0, 0, 0, 1);
    }
    
    



    
    function nextExist(ItemWrapper storage itemWrapper) internal view returns(bool) {
        return itemWrapper.nearbyWrappers[true] > 0;
    }
    
    function prevExist(ItemWrapper storage itemWrapper) internal view returns(bool) {
        return itemWrapper.nearbyWrappers[false] > 0;
    }
    
    function setNearbys(ItemWrapper storage itemWrapper, uint256 prev, uint256 next) private {
        itemWrapper.nearbyWrappers[true] = next;
        itemWrapper.nearbyWrappers[false] = prev;
    }

    function rootExist(List storage list) internal view returns(bool) {
        return list.rootId > 0;
    }

    function addToInternalArray(List storage list, TestItem memory item) private returns(uint256){
        uint256 itemId = 0;
        if (list.freeIndexesLength > 0) {
            itemId = list.freeIndexes[list.freeIndexesLength - 1];
            list.freeIndexesLength = SafeMath.sub(list.freeIndexesLength, 1);
            
            list.wrappers[itemId] = ItemWrapper(item);
        }
        else {
            //require(list.manager.listToNextWrapperId[list.id] == 1, "next index is zero!!!");
            itemId = list.nextWrapperId;
            list.nextWrapperId = SafeMath.add(list.nextWrapperId, 1);
            list.wrappers[itemId] = ItemWrapper(item);
        }
        
        return itemId;
    }
    
    function get(List storage list, uint256 index) internal view returns(TestItem storage) {
        require(index < list.length, "Out of range exception");
        
        uint256 currentItemId = list.rootId;
        for (uint256 i = 1; i <= index; i = SafeMath.add(i, 1)){
            currentItemId = list.wrappers[currentItemId].nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
        }
        
        return list.wrappers[currentItemId].item;
    }

    function last(List storage list) internal view returns(TestItem storage) {
        require(list.lastId != 0, "List does not have elements");
        return list.wrappers[list.lastId].item;
    }
    
    function add(List storage list, TestItem memory item) internal {
        uint256 newItemId = addToInternalArray(list, item);
        if (!rootExist(list)) {
            list.rootId = newItemId;
        }
        else {
            list.wrappers[list.lastId].nearbyWrappers[true] = newItemId;
            setNearbys(list.wrappers[newItemId], list.lastId, 0);
        }
        list.lastId = newItemId;
        list.length = SafeMath.add(list.length, 1);
    }
    
    function insert(List storage list, TestItem memory item, uint256 index) internal {
        require(index < list.length, "Out of range exception");
        
        uint256 newItemId = addToInternalArray(list, item);
        if (index == 0) {
            uint256 rootId = list.rootId;
            setNearbys(list.wrappers[newItemId], 0, rootId);
            list.wrappers[rootId].nearbyWrappers[false] = newItemId;
            
            list.rootId = newItemId;
        }
        else {
            uint256 currentItemId = list.rootId;
            for (uint256 i = 1; i <= index; i = SafeMath.add(i, 1)){
                currentItemId = list.wrappers[currentItemId].nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
            }
            
            ItemWrapper storage nextWrapper = list.wrappers[currentItemId];
            ItemWrapper storage prevWrapper = list.wrappers[nextWrapper.nearbyWrappers[false]];
            ItemWrapper storage currentWrapper = list.wrappers[newItemId];
            
            prevWrapper.nearbyWrappers[true] = newItemId;
            nextWrapper.nearbyWrappers[false] = newItemId;
            setNearbys(currentWrapper, nextWrapper.nearbyWrappers[false], currentItemId);
        }
        
        list.length = SafeMath.add(list.length, 1);
    }
    
    function removeById(List storage list, uint256 index) internal {
        require(index < list.length, "Out of range exception");
        
        uint256 itemIdToRemove = list.rootId;
        for (uint256 i = 1; i <= index; i = SafeMath.add(i, 1)){
            itemIdToRemove = list.wrappers[itemIdToRemove].nearbyWrappers[true]; //берём текущий враппер и берём у него id следующего
        }
        uint256 nextId = list.wrappers[itemIdToRemove].nearbyWrappers[true];
        uint256 prevId = list.wrappers[itemIdToRemove].nearbyWrappers[false];
        
        if (index == list.length - 1) list.lastId = prevId;
        
        if (index == 0) list.rootId = nextId;
        else {
            list.wrappers[prevId].nearbyWrappers[true] = nextId;
            if(nextId != 0) list.wrappers[nextId].nearbyWrappers[false] = prevId;
        }

        list.freeIndexes[list.freeIndexesLength] = itemIdToRemove;
        list.freeIndexesLength = SafeMath.add(list.freeIndexesLength, 1);
        
        list.length = SafeMath.sub(list.length, 1);
    }
    
    function toArray(List storage list) internal view returns(TestItem[] memory) {
        TestItem[] memory itemsArray = new TestItem[](list.length);
        if (!rootExist(list)) return itemsArray;
        
        uint256 currentItemId = list.rootId;
        itemsArray[0] = list.wrappers[currentItemId].item;
        
        for (uint256 i = 1; i < list.length; i = SafeMath.add(i, 1)) {
            currentItemId = list.wrappers[currentItemId].nearbyWrappers[true];
            itemsArray[i] = list.wrappers[currentItemId].item;
        }
        
        return itemsArray;
    }
}