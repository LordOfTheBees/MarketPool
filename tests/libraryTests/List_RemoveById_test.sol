pragma solidity >=0.5.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../../library/Lists/List.sol";

contract List_test {
    using List for List.List;
    using List for List.ItemWrapper;
    using List for List.TestItem;
    
    List.List list;
    
    function checkRemoveById() public {
        list = List.createList();

        list.add(List.TestItem("9"));  // id 1
        list.add(List.TestItem("10")); // id 2
        list.add(List.TestItem("13")); // id 3
        list.insert(List.TestItem("11"), 2); // id 4
        list.insert(List.TestItem("12"), 3); // id 5

        Assert.equal(list.rootId, 1, "err 0");

        uint256 nextId = list.wrappers[list.rootId].nearbyWrappers[true];
        Assert.equal(nextId, 2, "err 1");

        nextId = list.wrappers[nextId].nearbyWrappers[true];
        Assert.equal(nextId, 4, "err 2");

        nextId = list.wrappers[nextId].nearbyWrappers[true];
        Assert.equal(nextId, 5, "err 3");

        nextId = list.wrappers[nextId].nearbyWrappers[true];
        Assert.equal(nextId, 3, "err 4");

        list.removeById(1);
        Assert.equal(list.length, 4, "1. Length incorrect");
        Assert.equal(list.rootId, 1, "1. RootId incorrect");
        Assert.equal(list.get(0).data, "9", "1. List[0] has incorrect data");
        Assert.equal(list.get(1).data, "11", "1. List[1] has incorrect data");
        Assert.equal(list.get(2).data, "12", "1. List[2] has incorrect data");
        Assert.equal(list.get(3).data, "13", "1. List[3] has incorrect data");

        list.removeById(0);
        Assert.equal(list.length, 3, "2. Length incorrect");
        Assert.equal(list.rootId, 4, "2. RootId incorrect");
        Assert.equal(list.get(0).data, "11", "2. List[0] has incorrect data");
        Assert.equal(list.get(1).data, "12", "2. List[1] has incorrect data");
        Assert.equal(list.get(2).data, "13", "Test 2. List[2] has incorrect data");

        list.add(List.TestItem("9"));
        Assert.equal(list.length, 4, "3. Length incorrect");
        Assert.equal(list.get(0).data, "11", "3. List[0] has incorrect data");
        Assert.equal(list.get(1).data, "12", "3. List[1] has incorrect data");
        Assert.equal(list.get(2).data, "13", "3. List[2] has incorrect data");
        Assert.equal(list.get(3).data, "9", "3. List[3] has incorrect data");

        list.insert(List.TestItem("10"), 0);
        Assert.equal(list.length, 5, "4. Length incorrect");
        Assert.equal(list.get(0).data, "10", "4. List[0] has incorrect data");
        Assert.equal(list.get(1).data, "11", "4. List[1] has incorrect data");
        Assert.equal(list.get(2).data, "12", "4. List[2] has incorrect data");
        Assert.equal(list.get(3).data, "13", "4. List[3] has incorrect data");
        Assert.equal(list.get(4).data, "9", "4. List[4] has incorrect data");
    }
}