pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/* Internal Imports */
import {DataTypes} from "./DataTypes.sol";
import {MerkleUtils} from "./MerkleUtils.sol";
import {TransitionEvaluator} from "./TransitionEvaluator.sol";


contract RollupChain {
    using SafeMath for uint256;

    TransitionEvaluator transitionEvaluator;
    MerkleUtils merkleUtils;
    DataTypes.Block[] public blocks;
    bytes32 public constant ZERO_BYTES32 = 0x0000000000000000000000000000000000000000000000000000000000000000;
    uint256 constant STATE_TREE_HEIGHT = 32;
    // TODO: Set a reasonable wait period
    uint256 constant WITHDRAW_WAIT_PERIOD = 0;

    address public committerAddress;

    /* Events */
    event RollupBlockCommitted(uint256 blockNumber, bytes[] transitions);

    constructor(
        address _transitionEvaluatorAddress,
        address _merkleUtilsAddress,
        address _committerAddress
    ) public {
        transitionEvaluator = TransitionEvaluator(_transitionEvaluatorAddress);
        merkleUtils = MerkleUtils(_merkleUtilsAddress);
        committerAddress = _committerAddress;
    }

    modifier onlyCommitter() {
        require(
            msg.sender == committerAddress,
            "Only the committer may submit blocks"
        );
        _;
    }

    function commitBlock(
        uint256 _blockNumber,
        bytes[] calldata _transitions
    ) external onlyCommitter returns (bytes32) {
        require(_blockNumber == blocks.length, "Wrong block number");

        bytes32 root = merkleUtils.getMerkleRoot(_transitions);
        DataTypes.Block memory rollupBlock = DataTypes.Block({
            rootHash: root,
            blockSize: _transitions.length
        });

        blocks.push(rollupBlock);
        return root;
    }

    function verifyWithdrawTransition(
        address _account,
        DataTypes.IncludedTransition memory _includedTransition
    ) public view returns (bool) {
        require(
            checkTransitionInclusion(_includedTransition),
            "Withdraw transition must be included"
        );
        require(
            transitionEvaluator.verifyWithdrawTransition(
                _account,
                _includedTransition.transition
            ),
            "Withdraw signature is invalid"
        );

        require(
            getCurrentBlockNumber() -
                _includedTransition.inclusionProof.blockNumber >=
                WITHDRAW_WAIT_PERIOD,
            "Withdraw wait period not passed"
        );
        return true;
    }


    function checkTransitionInclusion(
        DataTypes.IncludedTransition memory _includedTransition
    ) public view returns (bool) {
        bytes32 rootHash = blocks[_includedTransition
            .inclusionProof
            .blockNumber]
            .rootHash;
        bool isIncluded = merkleUtils.verify(
            rootHash,
            _includedTransition.transition,
            _includedTransition.inclusionProof.transitionIndex,
            _includedTransition.inclusionProof.siblings
        );
        return isIncluded;
    }

    function getCurrentBlockNumber() public view returns (uint256) {
        return blocks.length - 1;
    }
}