pragma solidity >=0.5.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../../library/Lists/List.sol";

contract List_test {
    using List for List.List;
    using List for List.TestItem;
    
    List.List list;
    
    function checkRoot() public {
        list = List.createList();
        
        Assert.equal(list.rootExist(), false, "root exist");
        list.add(List.TestItem("10"));
        Assert.equal(list.rootId > 0, true, "rout is zero");
        Assert.equal(list.rootExist(), true, "rout does not exist");
        Assert.equal(list.get(0).data, "10", "incorrect root data");
        
        list.add(List.TestItem("11"));
        Assert.equal(list.rootId, 1, "incorrect rootId");
    }
    
    function checkAddGetFunctions() public {
        list = List.createList();
        
        Assert.equal(list.length, 0, "incorrect length, non zero");
        
        list.add(List.TestItem("10"));
        list.add(List.TestItem("11"));
        
        Assert.equal(list.length, 2, "incorrect length, not equal 2");
        Assert.equal(list.get(0).data, "10", "incorrect data by index 0, not equal '10'");
        Assert.equal(list.get(1).data, "11", "incorrect data by index 1, not equal '11'");
    }
    
    function checkInsertFunction() public {
        list = List.createList();
        
        list.add(List.TestItem("10"));
        list.add(List.TestItem("12"));
        list.insert(List.TestItem("9"), 0);
        
        Assert.equal(list.rootId, 3, "Insert to 0 index. Root id incorrect.");
        Assert.equal(list.get(0).data, "9", "Insert to 0 index. item[0] has incorrect data");
        Assert.equal(list.get(1).data, "10", "Insert to 0 index. item[1] has incorrect data");
        Assert.equal(list.get(2).data, "12", "Insert to 0 index. item[2] has incorrect data9");
        
        list.insert(List.TestItem("11"), 2);
        
        Assert.equal(list.get(0).data, "9", "Insert to 2 index. item[0] has incorrect data");
        Assert.equal(list.get(1).data, "10", "Insert to 2 index. item[1] has incorrect data");
        Assert.equal(list.get(2).data, "11", "Insert to 2 index. item[2] has incorrect data");
        Assert.equal(list.get(3).data, "12", "Insert to 2 index. item[3] has incorrect data");
        
        list.add(List.TestItem("13"));
        
        Assert.equal(list.length, 5, "After add '13'. Incorrect length, not equal 5");
        Assert.equal(list.get(0).data, "9", "Add func. Incorrect data by index 0, not equal '9'");
        Assert.equal(list.get(1).data, "10", "Add func. Incorrect data by index 1, not equal '10'");
        Assert.equal(list.get(2).data, "11", "Add func. Incorrect data by index 2, not equal '11'");
        Assert.equal(list.get(3).data, "12", "Add func. Incorrect data by index 3, not equal '12'");
        Assert.equal(list.get(4).data, "13", "Add func. Incorrect data by index 4, not equal '13'");
    }
}