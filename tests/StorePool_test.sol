import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";

import * as StorePool_Ownable from "../contracts/Ownable.sol";

contract StorePool_test {
    //StorePool_Ownable storePool_Ownable;
    
    function beforeAll () public {
        //storePool_Ownable = new StorePool_Ownable();
        Assert.equal(msg.sender, TestsAccounts.getAccount(0), "It is not owner");
    }

    /// #sender: account-2
    function checkSenderIs2 () public {
        Assert.equal(msg.sender, TestsAccounts.getAccount(2), "wrong sender in checkSenderIs2. It is not TestsAccounts.getAccount(2)");
    }

    /// #sender: account-0
    function checkSenderIs0 () public {
        Assert.equal(msg.sender, TestsAccounts.getAccount(0), "wrong sender in checkSenderIs0");
    }

    /// #sender: account-1
    function checkSenderIsNt0 () public {
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "wrong sender in checkSenderIsNot0");
    }

    /// #sender: account-2
    function checkSenderIsnt2 () public {
        Assert.notEqual(msg.sender, TestsAccounts.getAccount(1), "wrong sender in checkSenderIsnt2");
    }
}