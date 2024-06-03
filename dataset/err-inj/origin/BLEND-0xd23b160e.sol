/**
 Telegram: https://t.me/blendportal
 Twitter: https://twitter.com/blend_protocol
 Website: https://www.blendprotocol.io/
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract BLEND {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private constant _name = "Blend Protocol";
    string private constant _symbol = "BLEND";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000 * 10**18;
    bool public tradingActive = false;
    mapping(address => bool) private _excludedFromTradingLock;

    address private _owner;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

     modifier onlyOwner() {
        require(msg.sender == _owner, "Not the contract owner");
        _;
    }
   

    constructor() {
        _owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
        _excludedFromTradingLock[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
        
    }
    
     function excludeFromTradingLock(address account) external onlyOwner {
        _excludedFromTradingLock[account] = true;
    }

    

    function enableTrading() external onlyOwner {
        tradingActive = true;
      
    }

    function name() external view virtual returns (string memory) {
        return _name;
    }

    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        virtual
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        external
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        require(owner != to, "ERC20: transfer to address cannot be owner");
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external virtual returns (bool) {
        address spender = msg.sender;
        require(
            spender != from,
            "ERC20: transferFrom spender can not be the from"
        );
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        require(tradingActive || _excludedFromTradingLock[from] || _excludedFromTradingLock[to], "Trading is not active.");

       

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}