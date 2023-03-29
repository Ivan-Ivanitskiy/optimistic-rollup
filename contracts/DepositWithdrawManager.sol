pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {DataTypes} from "./DataTypes.sol";
import {RollupChain} from "./RollupChain.sol";
import {TransitionEvaluator} from "./TransitionEvaluator.sol";
import {AccountRegistry} from "./AccountRegistry.sol";


contract DepositWithdrawManager {
    mapping(address => uint256) public depositNonces;
    mapping(address => uint256) public withdrawNonces;

    event Deposit(address account, uint256 amount);
    event Withdraw(address account, uint256 amount);

    RollupChain rollupChain;
    TransitionEvaluator transitionEvaluator;
    AccountRegistry accountRegistry;

    constructor(
        address _rollupChainAddress,
        address _transitionEvaluatorAddress,
        address _accountRegistryAddress
    ) public {
        rollupChain = RollupChain(_rollupChainAddress);
        transitionEvaluator = TransitionEvaluator(_transitionEvaluatorAddress);
        accountRegistry = AccountRegistry(_accountRegistryAddress);
    }

    function registerAccount(
        address _account,
        bytes calldata _registerSignature
    ) external {
        accountRegistry.registerAccount(_account, _registerSignature);
    }

    function deposit(
        address _account
    ) public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        emit Deposit(_account, msg.value);
        depositNonces[_account]++;
    }

    function withdraw(
        address _account,
        DataTypes.IncludedTransition memory _includedTransition,
        bytes memory _signature
    ) public {
        require(
            rollupChain.verifyWithdrawTransition(_account, _includedTransition),
            "Withdraw transition invalid"
        );
        DataTypes.WithdrawTransition memory withdrawTransition = transitionEvaluator
            .decodeWithdrawTransition(_includedTransition.transition);
        uint256 withdrawNonce = withdrawTransition.nonce;
        uint256 amount = withdrawTransition.amount;
        bytes32 withdrawHash = keccak256(
            abi.encodePacked(
                address(this),
                "withdraw",
                _account,
                amount,
                withdrawNonce
            )
        );
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(withdrawHash);
        require(
            ECDSA.recover(prefixedHash, _signature) == _account,
            "Withdraw signature is invalid!"
        );
        require(
            withdrawNonce == withdrawNonces[_account],
            "Wrong withdraw nonce"
        );
        withdrawNonces[_account]++;

        payable(msg.sender).transfer(amount);
        emit Withdraw(_account, amount);
    }
}
