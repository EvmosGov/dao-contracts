## OZ Governor
One of the most important aspects of a successful DAO is voting on issues that impact all members of the organization, and Blockchain presents a natural progression to the voting process. 


## Technical Demonstration:

OpenZeppelin provides a library of smart contracts code that is community-vetted and has been thoroughly tested in production, making it an ideal starting point for any developer looking to get started with writing smart contracts. They provide battle-tested implementations of the ERC (Ethereum Request for Comment) standards.

This project is a simple DOA using OpenZeppelin Governor, which is provided specifically for DOA applications. Here is the scenario: 

Members of a DAO **(Token Holders)** called ‘Direct-Democracy’ want to build a gym. They need to create a proposal to vote **(Governance)** on that, if approved, will release predetermined funds from a communal bank **(Treasury)** to a builders cooperative **(Recipient)**. This money will be transferred after a time delay **(TimeLock)**.

First, let’s define the roles simply:

```
- Token Holders (Voters) → The people who will cast the votes on proposals.
- Treasury → A community bank where the budget is stored.
- Recipient → Once a vote is approved, the money will be released to this entity.
```
To achieve this, we will need 5 smart-contracts on the blockchain, let’s define them:
```
1. Token (ERC20Votes) → The cryptocurrency which the voters will own, and need to own to be members of the DAO and able to vote on proposals. In our example this token is called ‘govEVMOS’.
2. Treasury → Where the funds are stored. The votes are to decide what to do with these funds.
3. Recipient → Where the funds will be sent to once a proposal has been approved. In our example, the builders cooperative.
4. Governance → Where proposals are created. In our example, there is an encoded function that will call on the treasury contract to release the funds.
5. TimeLock → A time delay imposed by the governance before firing the encoded function, if the proposal passes.
```

## Vesting Contracts

VestingWallet `(contracts/finance/VestingContract.sol)` handles the vesting of native EVM tokens as well as ERC20 tokens for a given beneficiary. Custody of multiple tokens can be given to this contract, which will release the token to the beneficiary following a given, customizable, vesting schedule.



## Functions
| Function Name |  Action  | Description | Can only be called by the owner? |
| ------ | ------ | ------ | ------ |
| createVestingSchedule | #UpdateAction | Have the role in creating a vesting schedule for the user | True
| revoke | #UpdateAction | Revokes the vesting schedule for a certain user | True
| withdraw | #UpdateAction | Contract Owner uses this to withdraw any remaining tokens that don't get vested | True
| release | #Update Action | The vested investor can call this to retrieve the tokens that gets unlocked in accordance with the vesting schedule | False
| getVestingScheduleByAddressAndIndex | #Read Action | Returns the deatils about the vesting schedule | False
|computeReleasableAmount| #Read Action | Returns the releasble amount of tokens from vesting schedule at the giving time | False
|getVestingSchedulesCountByBeneficiary| #Read Action | Returns the beneficiary of the vesting schedule | False
| getVestingIdAtIndex | #Read Action | Returns the vesting schedule id at a given investment index | False
| getVestingScheduleByAddressAndIndex | #Read Action | Returns all vestign schedules infos based on beneficiary and the investment index | False
|getVestingSchedulesTotalAmount | # Read Action | Returns the total amount of tokens that are vested | False
| getToken | #Read Action | Returns the address of the vested token | False |
|getWithdrawableAmount| #Read Action | Returns the amount of tokens that can be withdrawable | False
| computeNextVestingScheduleIdForHolder | #Read Action | Returns the vestign schedule id for an beneficiary based on the next investment index | False
| getLastVestingScheduleForHolder | #Read Action | Returns the latest vesting schedule for a beneficiary | False
| computeVestingScheduleIdForAddressAndIndex | #Read Action | Return the vesting schedule id for an given address and a given investment index | False



## Parameters
#### 1) createVestingSchedule
| Parameter Name | Explanation | 
| ---- | ---- |
| _beneficiary | This parameter represents the vesting beneficiary, basically the early investor that choosed to buy in the seed phase and have his token vested |
| _start | Represents the start timestamp of the vested period |
| _cliff | Represents the cliff period of the vested period, basically a lock period, for example if a vested period of 1 year have a cliff of 6 months it means that the first 6 months when the tokens unlock the beneficiary will not be able to withdraw anything but after that 6 months period end the beneficiary will be able to withdraw the tokens for the all 6 months |
| _duration | The duration of the vested period |
| _slicePeriodSeconds |  Represents what amount of tokens gets unlocked per second | 
| _revocable | A boolean that gives the owner the ability to revoke or not the vesting schedule for the beneficiary, if the value is set as True, then the owner will have the capabilities to later revoke the vesting schedule from the beneficiary, if it's set as False, the owner will never be able to revoke the vesting schedule from beneficiary |
| _amount| The amount of tokens that will be vested | 


#### 2) revoke
| Parameter Name | Explanation | 
| ---- | ---- |
| vestingScheduleId | Represents the id of the vesting schedule, it's a form to identifie an unique vesting schedule |


#### 3) withdraw
| Parameter Name | Explanation | 
| ---- | ---- |
| amount | Reperesent the token amount that the owner wants to withdraw  |

#### 4) release
| Parameter Name | Explanation | 
| ---- | ---- |
| vestingScheduleId | Reperesent the unique vesting schedule id that is use to indetify the vesting schedule for a particularry beneficiary  |
| amount | Reperesent the token amount that the beneficiary wants to retrieve, it have to be equal with the amount that the vested schedule have uncloked so far |

#### 5) getVestingScheduleByAddressAndIndex
| Parameter Name | Explanation |
| ---- | ---- |
| holder | Represents the beneficiary |
| index  | The index for a particulary vesting schedule for a holder | 

#### 6) computeReleasableAmount
| Parameter Name | Explanation |
| ---- | ---- |
| id | Represents the vesting schedule id |

#### 7) getVestingSchedulesCountByBeneficiary
| Parameter Name | Explanation |
| ---- | ---- |
| _beneficiary | Represents the beneficiary of the vesting schedule |

#### 8) getVestingIdAtIndex
| Parameter Name | Explanation |
| ---- | ---- |
| index | Represents the index of the investment the beneficiary makes |

#### 9) getVestingScheduleByAddressAndIndex
| Parameter Name | Explanation |
| ---- | ---- |
| holder | Represents the beneficiary of the vesting schedule |
| index | Represents the index of the investment the beneficiary makes |

#### 10) getVestingSchedulesTotalAmount
     No Parameters.

#### 11) getToken
     No Parameters.

#### 12) getWithdrawableAmount
     No Parameters.

#### 13) computeNextVestingScheduleIdForHolder
| Parameter Name | Explanation |
| ---- | ---- |
| holder | Represents the beneficiary of the vesting schedule |


#### 14) getLastVestingScheduleForHolder
| Parameter Name | Explanation |
| ---- | ---- |
| holder | Represents the beneficiary of the vesting schedule |

#### 15) computeVestingScheduleIdForAddressAndIndex
| Parameter Name | Explanation |
| ---- | ---- |
| holder | Represents the beneficiary of the vesting schedule |
| index | Represents the index of the investment the beneficiary makes |


## Main Flow

1. Contract Owner creates a vestign schedule for an investor calling the ``` createVestingSchedule ``` function.
2. A beneficiary can keep track of his vesting schedules by calling ```getVestingScheduleByAddressAndIndex```, this will return all the infos
3. After the cliff period have ended, an beneficiary can call the relase function to release the unlocked amount of his tokens.
4. If all the vesting schedules are finished and there are still tokens in the  contract, the admin can call the withdraw function and retrieve the unvested tokens.
5. ```[OPTIONAL]``` The contract admin can call at any time the revoke function, to revoke the vesting schedule of an beneficiary, basically removing his vested tokens.



## How to calculate
The formula for calculating the vested amount is vestedAmount = vestingScheduleAmountTotal * (vestedSeconds / vestingScheduleDuration)
vestingScheduleAmountTotal = Represents the total amount of tokens that are vested over the vesthing schedule duration
vestedSeconds = Represents the total amount of seconds that have passed since the start of the vesting schedule
vestingScheduleDuration = Represents the total duration of the vested schedule (ex: 12 months, 15 months, 24 months, etc...)
Example:
vestingScheduleAmountTotal = 40000
vestedSeconds = 2629743 (seconds in a month)
vestinScheduleDuration = 63113851 (seconds in 2 years)
=> 40000 * (2629743 / 63113851 ) =  40000 * 0,04166 = 1666,4 ->  the amount of tokens that unlock per 1 month
              