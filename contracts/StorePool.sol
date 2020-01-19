pragma solidity >=0.5.0;

import "../node_modules/OpenZeppelin/contracts/math/SafeMath.sol";
import "./Ownable.sol";

/**
 * @author LordOfTheBees
 * @notice Workplace with Store
 */
contract StorePool is StorePool_Ownable {
    using SafeMath for uint256;

    event StoreCreated(uint256 indexed storeId);
    event StoreOwnershipTransferred(uint256 indexed storeId, address indexed previousOwner, address indexed newOwner);

    struct Store {
        string name;
    }

    //Список созданных маркетов
    Store[] public stores;

    // ID магазина и их владельцы
    mapping (uint256 => address) storeToOwner;


    /**
     * @notice Create new Store for sender.
     * @param name The name of storeplace
     * @return id of the created store
     */
    function createStore(string memory name) public returns (uint256) {
        stores.push(Store(name));
        uint256 id = SafeMath.sub(stores.length, 1);
        storeToOwner[id] = msg.sender;
        emit StoreCreated(id);
        return id;
    }

    /**
     * @notice Renouncing ownership will leave the contract without an store owner, thereby removing any functionality that is only available to the store owner (e.g. creating new Item Types).
     */
    function renounceStoreOwnership(uint256 storeId) public onlyStoreOwner(storeId) {
        emit StoreOwnershipTransferred(storeId, storeToOwner[storeId], address(0));
        storeToOwner[storeId] = address(0);
    }

    /**
     * @notice Transfers ownership of the ('storeId') to a new account (`newOwner`).
     */
    function transferStoreOwnership(uint256 storeId, address newOwner) public onlyStoreOwner(storeId) {
        require(newOwner != address(0), "StorePool: New owner is the zero address");
        emit StoreOwnershipTransferred(storeId, storeToOwner[storeId], newOwner);
        storeToOwner[storeId] = newOwner;
    }
    
    
    
    
    
    function getStoreOwner(uint256 storeId) public view returns (address) {
        require(storeExist(storeId), "StorePool: Store does not exist");
        return storeToOwner[storeId];
    }
    
    /**
     * @notice Chech if it is store owner 
     */
    function isStoreOwner(uint256 storeId) public view returns (bool) {
        require(storeExist(storeId), "StorePool: Store does not exist");
        return storeToOwner[storeId] == msg.sender;
    }
    
    /**
     * @notice Check if store exist 
     */
    function storeExist(uint256 storeId) public view returns (bool) {
        return stores.length > storeId;
    }





    modifier onlyStoreOwner(uint256 storeId) {
        require(storeExist(storeId), "StorePool: Store does not exist");
        require(storeToOwner[storeId] == msg.sender, "StorePool: Caller is not the owner");
        _;
    }
}
