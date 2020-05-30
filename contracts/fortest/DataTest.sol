// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import '../common/ContractSubscriber.sol';

contract DataTest is ContractSubscriber {
    address dataAddress = address(0);

    function saveDataAddress(address data) external onlySubscriber {
        dataAddress = data;
    }

    function getDataAddress() public view returns (address) {
        return dataAddress;
    }
}