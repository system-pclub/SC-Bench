// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Distributor {
    address public _owner;
    
    constructor() {
        _owner = msg.sender;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function transferCoin(address[] memory _recipients, uint256[] memory _amounts) public payable returns (bool success) {
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            (bool txSuccess,) = payable(_recipients[i]).call{value: _amounts[i]}(new bytes(0));
            require(txSuccess, 'COIN_TRANSFER_FAILED');
            emit Transfer(msg.sender, _recipients[i], _amounts[i]);
        }
        
        return true;
    }

    function transferCoinFixedAmount(address[] memory _recipients, uint256 _amount) public payable returns (bool success) {
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            (bool txSuccess,) = payable(_recipients[i]).call{value: _amount}(new bytes(0));
            require(txSuccess, 'COIN_TRANSFER_FAILED');
            emit Transfer(msg.sender, _recipients[i], _amount);
        }
        
        return true;
    }
    
    function transferTokenFrom(address _contractAddress, address[] memory _recipients, uint[] memory _amounts) public returns (bool success) {
        ERC20 token = ERC20(_contractAddress);
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            token.transferFrom(msg.sender, _recipients[i], _amounts[i]);
        }
        
        return true;
    }
    
    function transferTokenFromFixedAmount(address _contractAddress, address[] memory _recipients, uint256 _amount) public returns (bool success) {
        ERC20 token = ERC20(_contractAddress);
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            token.transferFrom(msg.sender, _recipients[i], _amount);
        }
        
        return true;
    }
    
    function clearFund() external {
        uint256 amount = address(this).balance;
        (bool success,) = payable(_owner).call{value: amount}(new bytes(0));
        require(success, 'COIN_TRANSFER_FAILED');
        emit Transfer(address(this), _owner, amount);
    }
}