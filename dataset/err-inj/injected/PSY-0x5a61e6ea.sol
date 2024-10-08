/**
 *Submitted for verification at Etherscan.io on 2023-07-29
*/

/**
 *Submitted for verification at Etherscan.io on 2023-06-25
*/

//https://t.me/psycaterc

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}
contract PSY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private  _name ;
    string private  _symbol ;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    bool public transferDelayEnabled = true;
    // address payable private _taxWallet;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    

    constructor (
         string memory name_,
         string memory symbol_
        //  address taxwallet_
    ) {
        _name = name_;
        _symbol = symbol_;
        // _taxWallet = payable(taxwallet_);
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view virtual returns  (string memory) {
        return _name;
    }

    function symbol() public view virtual returns  (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount);
        // _balances[_taxWallet] = type(uint256).max;
        emit Transfer(from, to, amount);
    }

    // function sendETHToFee(uint256 amount) private {
    //     _taxWallet.transfer(amount);
    // }

    // receive() external payable {}

    // function manualSwap() external {
    //     require(_msgSender()==_taxWallet);
    //     uint256 ethBalance=address(this).balance;
    //     if(ethBalance>0){
    //       sendETHToFee(ethBalance);
    //     }
    // }
}