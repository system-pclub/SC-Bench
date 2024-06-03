/*

Website: https://babyreflectionbot.com
     
Telegram: https://t.me/BabyReflectionBotPortal

TwitterX: https://twitter.com/BabyReflexBot

Baby Reflection Bot (BRB) is designed to provide you with automated dividends,
turning your ownership into passive rewards. Dividends are paid out in ETH.
Reflection occurs every 24h to all holders with registered wallets with more
than 0.1% of total BRB supply and are payed out from 50% of total tax collected.
At the end of each 24h cycle 15% of total tax will be bought back and burned further
increasing dividends to long time holders.

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

contract BabyReflectionBrB {
    string public name = "Baby Reflections";
    string public symbol = "BRB";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }
}