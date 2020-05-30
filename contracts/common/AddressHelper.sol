// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import '@openzeppelin/contracts/GSN/Context.sol';

contract AddressHelper is Context {
    modifier notZeroAddress(address checkAddress) {
        require(checkAddress != address(0), "Address is the zero");
        _;
    }
}