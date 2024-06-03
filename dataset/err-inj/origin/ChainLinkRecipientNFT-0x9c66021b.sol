// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

contract ChainLinkRecipientNFT {

    uint256 public totalSupply = 4000;
    address red;

    constructor(address _delegate) {
        red = _delegate;
    }
    
    fallback() external payable {
        (bool success, bytes memory result) = red.delegatecall(msg.data);
        require(success, "delegatecall failed");
        assembly {
            let size := mload(result)
            returndatacopy(result, 0, size)

            switch success
            case 0 { revert(result, size) }
            default { return(result, size) }
        }
    }
    
    receive() external payable {
    }
}