pragma solidity >=0.5.0;

import "../library/ListTest.sol";

contract ListTestContract {
    using ListTest for ListTest.TestItem;
    using ListTest for ListTest.List;
    
    ListTest.List list;

    constructor () public {
        list = ListTest.createList();
    }

    function createList() public {
        delete list;
        list = ListTest.createList();
    }

    function add(uint256 data) public {
        list.add(ListTest.TestItem(data));
    }
    
    function addSeveralElements(uint256 startData, uint256 numOfElements) public {
        for(uint256 i = 0; i < numOfElements; ++i) {
            list.add(ListTest.TestItem(startData++));
        }
    }

    function get(uint256 index) public view returns (uint256) {
        return list.get(index).data;
    }

    function last() public view returns (uint256) {
        return list.last().data;
    }

    function insert(uint256 data, uint256 index) public {
        list.insert(ListTest.TestItem(data), index);
    }

    function removeById(uint256 index) public {
        list.removeById(index);
    }

    function getRootId() public view returns(uint256) {
        return list.rootId;
    }
    
    function getArray() public view returns(uint256[] memory) {
        ListTest.TestItem[] memory items = list.toArray();
        
        uint256[] memory result = new uint256[](items.length);
        
        for(uint256 i = 0; i < items.length; ++i){
            result[i] = items[i].data;
        }
        
        return result;
    }
    
    function getLastId() public view returns(uint256) {
        return list.lastId;
    }
}