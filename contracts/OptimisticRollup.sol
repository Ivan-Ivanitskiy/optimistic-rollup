pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract OptimisticRollup {
    using SafeERC20 for ERC20;

    address public owner;
    address public operator;
    address public validator;

    mapping (address => uint256) public balances;
    mapping (address => bool) public isRegistry;

    ERC20 public token;

    constructor(address _owner, address _operator, address _validator, ERC20 _token) public {
        owner = _owner;
        operator = _operator;
        validator = _validator;
        token = _token;
    }

    function addUserToRegistry(address user) public onlyOwner {
        require(!isRegistry[user], "User is already in the registry");
        isRegistry[user] = true;
    }

    function submitBlock(uint256[256] blockData) public onlyOperator {
        // Add code for operator to submit block data
    }

    function challengeBlock(uint256 blockIndex) public onlyValidator {
        // Add code for validator to challenge block
    }

    function deposit() public payable {
        require(isRegistry[msg.sender], "User must be in the registry to deposit");
        require(token.transferFrom(msg.sender, address(this), msg.value), "Token transfer failed");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        require(token.transfer(msg.sender, amount), "Token transfer failed");
        balances[msg.sender] -= amount;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Only the operator can perform this action");
        _;
    }

    modifier onlyValidator() {
        require(msg.sender == validator, "Only the validator can perform this action");
        _;
    }
}
