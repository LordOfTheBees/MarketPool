// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import '@openzeppelin/contracts/access/Ownable.sol';

contract EtherContract is Ownable {
    function donate() external payable {}
    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enought");
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }
}