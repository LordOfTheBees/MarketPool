pragma solidity >=0.5.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../../library/Lists/List.sol";

contract List_test {
    using List for List.List;
    using List for List.TestItem;
    
    List.List list;
    
    function checkToArray() public {
        list = List.createList();
        
        list.add(List.TestItem("10"));
        list.add(List.TestItem("12"));
        list.insert(List.TestItem("9"), 0);
        list.insert(List.TestItem("11"), 2);
        list.add(List.TestItem("13"));
        
        List.TestItem[] memory items = list.toArray();
        
        Assert.equal(items.length, list.length, "Length not equal betwen list and array");
        Assert.equal(items.length, 5, "Incorrect length");
        
        Assert.equal(items[0].data, "9", "Incorrect data by index 0, not equal '9'");
        Assert.equal(items[1].data, "10", "Incorrect data by index 1, not equal '10'");
        Assert.equal(items[2].data, "11", "Incorrect data by index 2, not equal '11'");
        Assert.equal(items[3].data, "12", "Incorrect data by index 3, not equal '12'");
        Assert.equal(items[4].data, "13", "Incorrect data by index 4, not equal '13'");
    }
}