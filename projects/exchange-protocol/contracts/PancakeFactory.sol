// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.5.16;

import './interfaces/IPancakeFactory.sol';
import './PancakePair.sol';
import {Register} from './interfaces/ISFS.sol';

contract PancakeFactory is IPancakeFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(PancakePair).creationCode));

    address SFSAddress;

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter, address _SFSAddress) public {
        feeToSetter = _feeToSetter;
        SFSAddress = _SFSAddress;
        Register(_SFSAddress).register(msg.sender);
    }

    function setSFSAddress(address newAddress) external {
        require(msg.sender == feeToSetter, 'Pancake: FORBIDDEN');
        SFSAddress = newAddress;
    }

    function changeSFSReceiver(address newReceiver) external {
        require(msg.sender == feeToSetter, 'Pancake: FORBIDDEN');
        Register(SFSAddress).register(newReceiver);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Pancake: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Pancake: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Pancake: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(PancakePair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IPancakePair(pair).initialize(token0, token1, SFSAddress);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Pancake: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Pancake: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
