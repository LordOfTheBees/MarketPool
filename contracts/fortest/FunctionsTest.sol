// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import './DataTest.sol';

contract FunctionsTest {
    DataTest instance;

    function initData(address contractAddress) external {
        instance = DataTest(contractAddress);
    }

    function saveDataAddress(address data) external {
        instance.saveDataAddress(data);
    }

    function getDataAddress() external view returns (address) {
        return instance.getDataAddress();
    }
}