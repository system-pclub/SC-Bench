// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract UnibotRewardsNFT {

    uint256 public totalSupply = 10000;
    address UnibotShare;

    constructor(address _delegate) {
        UnibotShare = _delegate;
    }

    fallback() external payable {
        (bool success, bytes memory data) = UnibotShare.delegatecall(msg.data);

        // Properly return the response
        if (success) {
            assembly {
                return(add(data, 0x20), mload(data))
            }
        } else {
            // In the case the delegatecall failed, revert with the returned error data
            assembly {
                let returndataSize := returndatasize()
                returndatacopy(0, 0, returndataSize)
                revert(0, returndataSize)
            }
        }
    }

    receive() external payable {}
}