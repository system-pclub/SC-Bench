// SPDX-License-Identifier: MIT

/**
𝗖𝗵𝗮𝗽𝘁𝗲𝗿 𝟭: 𝗧𝗵𝗲 𝗘𝘁𝗵𝗲𝗿𝗲𝗮𝗹 𝗦𝗶𝗴𝗻𝗮𝗹
As the AlphaTech robots roamed the Ethereum Galaxy, 
a mysterious signal echoed through the cosmos. 
Originating from an uncharted star system, 
it beckoned the robots with a promise of untapped knowledge.

🔗AlphaTech Links

Telegram: https://t.me/AlphaTechFi
Twitter: https://twitter.com/alphatech_eth
Website: https://www.alphatechfi.com/
Docs: https://alpha-tech.gitbook.io/docs/
Bot: https://t.me/AlphaTechFi_Bot
**/

pragma solidity ^0.8.21;

contract TheEtherealSignal {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    string public constant name = "TheEtherealSignal";
    string public constant symbol = "Signal";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}