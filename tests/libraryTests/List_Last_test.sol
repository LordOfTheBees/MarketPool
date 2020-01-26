pragma solidity >=0.5.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../../library/Lists/List.sol";

contract List_test {
    using List for List.List;
    using List for List.TestItem;
    
    List.List list;

    function checkLast() public {
        list = List.createList();
        
        list.add(List.TestItem("10"));
        list.add(List.TestItem("12"));
        list.insert(List.TestItem("9"), 0);
        list.insert(List.TestItem("11"), 2);
        
        Assert.equal(list.last().data, "12", "1. Last element incorrect");

        list.add(List.TestItem("13"));
        Assert.equal(list.last().data, "13", "2. Last element incorrect");

        list.removeById(4);
        Assert.equal(list.last().data, "12", "3. Last element incorrect");
    }
}