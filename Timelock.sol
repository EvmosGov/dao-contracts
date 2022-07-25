// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// A practical contract that delays the release of funds to the treasury after the proposal has passed.
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract Timelock is TimelockController {
    constructor(
        uint256 _minDelay,
        address[] memory _proposers,
        address[] memory _executors
    ) TimelockController(_minDelay, _proposers, _executors) {}
}
