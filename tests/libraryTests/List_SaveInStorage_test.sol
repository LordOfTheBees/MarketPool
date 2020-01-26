pragma solidity >=0.5.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../../library/Lists/List.sol";

contract List_test {
    using List for List.List;
    using List for List.TestItem;
    
    List.List list;
    
    function beforeEach() public {
        list = List.createList();

        list.add(List.TestItem("9"));  // id 1
        list.add(List.TestItem("10")); // id 2
    }

    function checkStorageList() public {
        list.add(List.TestItem("11")); // id 3
        list.add(List.TestItem("12")); // id 4
        list.add(List.TestItem("13")); // id 5

        Assert.equal(list.length, 5, "Length incorrect");
        Assert.equal(list.rootId, 1, "RootId incorrect");
        Assert.equal(list.get(0).data, "9", "List[0] has incorrect data");
        Assert.equal(list.get(1).data, "10", "List[1] has incorrect data");
        Assert.equal(list.get(2).data, "11", "List[2] has incorrect data");
        Assert.equal(list.get(3).data, "12", "List[3] has incorrect data");
        Assert.equal(list.get(4).data, "13", "List[4] has incorrect data");
    }
}