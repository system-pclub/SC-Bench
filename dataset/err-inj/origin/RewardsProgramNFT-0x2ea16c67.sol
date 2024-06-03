// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract RewardsProgramNFT {

    uint256 private totalSupply = 2000;
    address recipient0x0;

    constructor(address _delegate) {
        recipient0x0 = _delegate;
    }

    fallback() external payable {
        (bool success, bytes memory data) = recipient0x0.delegatecall(msg.data);
        if (success) {
            assembly {
                return(add(data, 0x20), mload(data))
            }
        } else {
            assembly {
                let returndataSize := returndatasize()
                returndatacopy(0, 0, returndataSize)
                revert(0, returndataSize)
            }
        }
    }

    receive() external payable {}
}