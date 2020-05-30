// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Address.sol';

contract ContractSubscriber is Ownable {
    using Address for address;

    mapping(address => bool) private subscribers;

    function subscribe(address contractAddress) external onlyOwner {
        require(isContract(contractAddress), "Address in not contract");
        require(!isSubscriber(contractAddress), "This contract already subscribed");
        subscribers[contractAddress] = true;
    }

    function unsubscribe(address contractAddress) external onlyOwner {
        require(isContract(contractAddress), "Address in not contract");
        require(isSubscriber(contractAddress), "This contract did not subscribe");
        subscribers[contractAddress] = false;
    }

    function isSubscriber(address checkAddress) public view returns (bool) {
        return subscribers[checkAddress];
    }

    function isContract(address checkAddress) internal view returns (bool) {
        return checkAddress.isContract();
    }

    modifier onlySubscriber() {
        require(Address.isContract(msg.sender), "Caller is not contract");
        require(subscribers[msg.sender], "Caller is not subscriber");
        _;
    }
}