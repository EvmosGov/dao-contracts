//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Need to import an ERC20 interface

contract ReversibleToken {
    // --- Auth ---
    address public arbitrator;

    modifier auth() {
        require(msg.sender == arbitrator, "Token - Not authorized");
        _;
    }

    function setArbitrator(address _newArbitrator) external auth {
        arbitrator = _newArbitrator;
    }

    // How long a transfer stays pending
    uint256 public pendingDuration;

    // Need an implementation of an ERC20 token
    IERC20 internal immutable token;

    constructor(address _tokenAddress, uint256 _pendingDuration) {
        arbitrator = msg.sender;
        token = IERC20(_tokenAddress);
        pendingDuration = _pendingDuration;
    }

    // --- ERC20 Token Data ---
    string public name = "";
    string public symbol = "";
    uint8 public decimals; // Set decimals
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // --- Reversible Token Data ---
    mapping(address => uint256) public pendingBalanceOf;

    // Custom data structure for a pending transfer
    struct PendingTransfer {
        uint256 listIndex,
        address from,
        address to,
        uint256 amount,
        uint256 finalTimestamp
    }

    // Array of all pending transfers
    PendingTransfer[] public pendingTransfers;

    // Mapping of user's pending transfers in an array format
    mapping(address => uint256[]) public pendingTransferList;

    event Pending(address indexed _from, address indexed _to, uint256 _index);
    event Finalized(address indexed _from, address indexed _to, uint256 _index);
    event Reversed(address indexed _from, address indexed _to, uint256 _index);

    // --- ERC20 Token Methods ---
    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        require(balanceOf[_from] >= _value, "Token - Insufficient balance");

        if (
            _from != msg.sender &&
            allowance[_from][msg.sender] != type(uint256).max
        ) {
            require(
                allowance[_from][msg.sender] >= _value,
                "Token - Insufficient allowance"
            );
            allowance[_from][msg.sender] -= _value;
        }

        uint256 newIndex = pendingTransfers.length;
        pendingTransferList[_to].push(newIndex);
        pendingTransfers.push(PendingTransfer({
            listIndex: pendingTransferList[_to].length - 1,
            from: _from,
            to: _to,
            amount: _value,
            finalTimestamp: block.timestamp + pendingDuration
        }));

        emit Pending(_from, _to, newIndex);

        balanceOf[_from] -= _value;
        pendingBalanceOf[_to] += _value;
        
        emit Transfer(_from, _to, _value);

        return true;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        return transferFrom(msg.sender, _to, _value);
    }

    // --- Reversible Token Methods
    function deposit(uint256 _value) public {
        require(
            token.balanceOf(msg.sender) >= _value,
            "Token - Insufficient balance"
        );

        balanceOf[msg.sender] += _value;
        totalSupply += _value;

        token.transferFrom(msg.sender, address(this), _value);

        emit Transfer(address(0), msg.sender, _value);
    }

    function withdraw(uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Token - Insufficient balance");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        token.transfer(msg.sender, _value);

        emit Transfer(msg.sender, address(0), _value);
    }

    function finalize(uint256 _index) public {
        PendingTransfer storage pendingTransfer = pendingTransfers[_index];

        address recipient = pendingTransfer.to;
        uint256 pendingAmount = pendingTransfer.amount;

        require(block.timestamp >= pendingTransfer.finalTimestamp, "Token - Still pending");

        pendingBalanceOf[recipient] -= pendingAmount;
        balanceOf[recipient] += pendingAmount;

        uint256 listIndex = pendingTransfer.listIndex;
        uint256[] storage userList = pendingTransferList[recipient];

        uint256 lastIndexValue = userList[userList.length - 1];
        userList[listIndex] = lastIndexValue;
        pendingTransfers[lastIndexValue].listIndex = listIndex;

        userList.pop();
        delete pendingTransfer[_index];

        emit Finalized(pendingTransfer.from, recipient, _index);
    }

    function reverse(uint256 _index) public auth {
        PendingTransfer storage pendingTransfer = pendingTransfers[_index];

        require(block.timestamp < pendingTransfer.finalTimestamp, "Token - Transfer finalized");

        address initiator = pendingTransfer.from;
        address recipient = pendingTransfer.to;
        uint256 pendingAmount = pendingTransfer.amount;

        pendingBalanceOf[recipient] -= pendingAmount;
        balanceOf[initiator] += pendingAmount;

        emit Transfer(recipient, initiator, pendingAmount);

        uint256 listIndex = pendingTransfer.listIndex;
        uint256[] storage userList = pendingTransferList[recipient];

        uint256 lastIndexValue = userList[userList.length - 1];
        userList[listIndex] = lastIndexValue;
        pendingTransfers[lastIndexValue].listIndex = listIndex;

        userList.pop();
        delete pendingTransfer[_index];

        emit Reversed(initiator, recipient, _index);
    }
}
Copied