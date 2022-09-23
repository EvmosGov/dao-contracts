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