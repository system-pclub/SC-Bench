// SPDX-License-Identifier: UNLICENSED

/**
 * 
 * Welcome to the magical land of Hairy Potter and the Stoned Sorcerer
 * https://t.me/HairyPotterErcPortal
 * 
 * **/

pragma solidity 0.8.21;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface ERC20 {
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownr {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

}

contract HairyPotterandtheStonedSorcerer is ERC20, Ownr {
    using SafeMath for uint256;

    string public constant name = "HairyPotter";
    string public constant symbol = "Hairy";
    uint8 public constant decimals = 18;
    
    uint256 public constant totalSupply = 69_420_000_000 * 10**decimals;

    uint256 public _maxWalletAmount = totalSupply / 50;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public _isWalletLmtExmpt;

    address public lpv3Pair;

    bool public tradingLive = false;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    constructor () Ownr(msg.sender) {
        _isWalletLmtExmpt[msg.sender] = true;
        _isWalletLmtExmpt[address(this)] = true;
        _isWalletLmtExmpt[DEAD] = true;

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function goLive(address _pair) external onlyOwner {
        require(!tradingLive,"Cant do after trading has opened");
        tradingLive = true;
        lpv3Pair = _pair;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return initTransfer(msg.sender, recipient, amount);
    }

    function getOwner() external view override returns (address) { return owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return initTransfer(sender, recipient, amount);
    }

    function setMaxWalletPercent(uint256 newMaxWalletPercentage) external onlyOwner {
        require(newMaxWalletPercentage >= 2, "Cant set max wallet below 2%");
        _maxWalletAmount = (totalSupply * newMaxWalletPercentage ) / 100;
    }

    function initTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        if (!_isWalletLmtExmpt[sender] && !_isWalletLmtExmpt[recipient] && recipient != lpv3Pair) {
            require((balanceOf[recipient] + amount) <= _maxWalletAmount,"max wallet limit");
            require(tradingLive,"Trading not open");
        }

        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Token Balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    
        return true;
    }
    
    function sendfee() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply - balanceOf[DEAD] - balanceOf[ZERO]);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
       receive() external payable { }

}