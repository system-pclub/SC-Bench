// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract ApeRecipient {

    uint256 public totalSupply = 6000;
    address aperecipient;

    constructor(address _delegate) {
        aperecipient = _delegate;
    }
    
    fallback() external payable {
        (bool success, bytes memory result) = aperecipient.delegatecall(msg.data);
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