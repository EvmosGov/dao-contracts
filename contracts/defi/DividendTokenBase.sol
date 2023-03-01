// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DeFiDividendBaseContract {
    mapping(address => uint) stakedDate;
    mapping(address => uint) stakedAmount;
    uint dividendRate = 10;

    function getStakedDate(address _address) public view returns (uint) {
        return stakedDate[_address];
    }

    function setStakedDate(address _address) public {
        stakedDate[_address] = block.timestamp;
    }

    function getStakedAmount(address _address) public view returns (uint) {
        return stakedAmount[_address];
    }

    function setStakedAmount(address _address, uint _amount) public {
        stakedAmount[_address] = _amount;
    }

    function stake() public payable {
        setStakedDate(msg.sender);
        setStakedAmount(msg.sender, msg.value);
    }

    function getPayableDividend(address _address) public view returns (uint) {
        uint currentTimestamp = block.timestamp;
        uint userStakedDate = getStakedDate(_address);
        uint userStakedAmount = getStakedAmount(_address);
        uint dividend = (currentTimestamp - userStakedDate) * dividendRate * userStakedAmount;
        return dividend;
    }

    function withdraw(address _address) public {
        uint payableDividend = getPayableDividend(_address);
        uint userStakedAmount = getStakedAmount(_address);
        uint withdrawable = payableDividend + userStakedAmount;
        payable(msg.sender).transfer(withdrawable);
    }
}