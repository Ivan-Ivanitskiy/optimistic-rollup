// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract DummyDepositWithdraw {
    mapping(address => uint256) private _balances;
    address public operator;

    event Deposit(address indexed src, uint indexed wad);
    event Withdrawal(address indexed dst, uint indexed wad);
    event Transfer(address indexed src, address indexed dst, uint indexed wad);

    constructor(address operator_) {
        operator = operator_;
    }

    modifier onlyOperator() {
        require(
            msg.sender == operator,
            "Only the operator may transfer"
        );
        _;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        _balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {    
        require(_balances[msg.sender] >= wad);
        _balances[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function transferFrom(address src, address dst, uint wad)
        public
        onlyOperator
        returns (bool)
    {
        require(_balances[src] >= wad);

        _balances[src] -= wad;
        _balances[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }

}