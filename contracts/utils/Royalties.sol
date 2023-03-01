// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract RoyaltyBaseContract {
    mapping(address => uint) public balances;
    address royaltyOwnerAddress;

    constructor() {}

    function deposit() payable public {
        address depositor = msg.sender;
        uint depositAmount = msg.value;
        uint royalteFee = getRoyaltyFee(depositAmount);

        balances[depositor] += depositAmount - royalteFee;
        payable(royaltyOwnerAddress).transfer(royalteFee);
    }

    function withdraw(uint amount) public {
        balances[msg.sender] -= amount;
    }

    function getRoyaltyFee(uint amount) pure public returns (uint) {
        return (amount * 10) / 100;
    }
}