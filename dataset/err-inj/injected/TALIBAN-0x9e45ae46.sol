/*
    $TALIBAN GANG

    T.me/WeDemBoyzPortal

    Twitter.com/TalibanSquad911

    https://talibaninthishoe.com/
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal _owner;
    event OwnershipTransferred(address _owner);
    constructor(address creatorOwner) { _owner = creatorOwner; }
    modifier onlyOwner() { require(msg.sender == _owner, "Only owner can call this"); _; }
    function owner() public view returns (address) { return _owner; }
    function renounceOwnership() external onlyOwner { 
        _owner = address(0); 
        emit OwnershipTransferred(address(0)); 
    }
}

contract TALIBAN is IERC20, Auth {
    string private constant _name         = unicode"I fucking said you are a pussy ass hoe, got it? I’ll have YOU know we ran y’all bitch ass niggas out of Afghanistan. I was blowing y’all up to smithereens before sleepy Joe called it off and didn’t want you motherfuckers to keep dropping like flies so keep telling lies. And we ran your profile, you have 8 meals cooked and 3 bathrooms cleaned you pussy ass liar, why are you telling people you have 300 confirmed kills, we don’t kill and tell, we run the stat sheets. We got you beat. You’ve never even been on the field. I’ve been rocking an AK-47 since 13 years old protecting the homeland. Russia tried and got fucked! USA tried and got manhandled. What, y’all think y’all did something? Bitch ass nigga we them boys! Y’all motherfuckers can’t do anything except submit to the devil. I call you to islam, but until then we’re enemies. Buddy is talking about secret spies and some other bullshit about IP’s. You’re a keyboard warrior. Pussy ass nigga see me on the playing field. Bitch ass nigga we them boys, we took over the government and fucking televised it. Y’all niggas throwing money to Ukraine with nothing to show for it pussy ass nigga you not a navyseal, keep it real.";
    string private constant _symbol       = "TALIBAN";
    uint8 private constant _decimals      = 18;
    uint256 private constant _totalSupply = 420_690_000_000_000 * (10**_decimals);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private _walletMarketing = payable(0xDD6c66e5dD9e8fFC67E824Cd307EA79b5758b597);
    uint256 private constant _taxSwapMin = _totalSupply *  1 / 10000;
    uint256 private constant _taxSwapMax = _totalSupply * 15 / 10000;
    uint256 private _maxTx;
    uint256 private _maxWallet;
    uint8 private _buyTaxRate;
    uint8 private _sellTaxRate;

    mapping (address => bool) private _noFees;
    mapping (address => bool) private _noLimits;
    mapping (address => bool) private _bots;

    address private constant _swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private _primarySwapRouter = IUniswapV2Router02(_swapRouterAddress);
    address private _primaryLP;
    mapping (address => bool) private _isLP;

    uint256 private _antiSnipeBlock;
    bool private _tradingOpen;

    bool private _inTaxSwap = false;
    modifier lockTaxSwap { 
        _inTaxSwap = true; 
        _; 
        _inTaxSwap = false; 
    }

    event TokensAirdropped(uint256 totalWallets, uint256 totalTokens);

    constructor() Auth(msg.sender) {
        address reservedWallet = address(0x92f964A2bcA69EA2aA0A62e01414B085665DA27F);
        _balances[reservedWallet] = _totalSupply * 120 / 1000;
        emit Transfer(address(0), reservedWallet, _balances[reservedWallet]);
        _balances[_owner] = _totalSupply - _balances[reservedWallet];
        emit Transfer(address(0), _owner, _balances[_owner]);

        _noFees[_owner] = true;
        _noFees[address(this)] = true;
        _noFees[_swapRouterAddress] = true;
        _noFees[_walletMarketing] = true;

        _noLimits[_owner] = true;
        _noLimits[address(this)] = true;
        _noLimits[_swapRouterAddress] = true;
        _noLimits[_walletMarketing] = true;

        _maxTx       = (_totalSupply * 5 / 1000) + (10**_decimals);
        _maxWallet   = (_totalSupply * 10 / 1000) + (10**_decimals);
        _buyTaxRate  = 2;
        _sellTaxRate = 3;
    }

    receive() external payable {}
    
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function taxBuy() external view returns (uint16) { return _buyTaxRate; }
    function taxSell() external view returns (uint16) { return _sellTaxRate; }
    function marketingWallet() external view returns (address) { return _walletMarketing; }
    function maxTransactionAmount() external view returns (uint256) { return _maxTx; }
    function maxWalletAmount() external view returns (uint256) { return _maxWallet; }
    function blacklists(address wallet) external view returns (bool) { return _bots[wallet]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(sender), "Trading not open");
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _approveRouter(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][_swapRouterAddress] < _tokenAmount ) {
            _allowances[address(this)][_swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), _swapRouterAddress, type(uint256).max);
        }
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(_primaryLP == address(0), "LP exists");
        require(!_tradingOpen, "trading is open");
        require(msg.value > 0 || address(this).balance>0, "No ETH in contract or message");
        require(_balances[address(this)]>0, "No tokens in contract");
        _primaryLP = IUniswapV2Factory(_primarySwapRouter.factory()).createPair(address(this), _primarySwapRouter.WETH());
        _addLiquidity(_balances[address(this)], address(this).balance);
        _isLP[_primaryLP] = true;
        _antiSnipeBlock = block.number + 3; // 3 blocks after adding liquidity
        _tradingOpen = true;
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveRouter(_tokenAmount);
        _primarySwapRouter.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function _markSniper(address wallet) private {
        if ( !_isLP[wallet] && wallet != address(this) && wallet != _swapRouterAddress ) {
            _bots[wallet] = true; 
        }
    }

    function _antiSnipe(address from, address to) private returns (bool) {
        bool isSafe = true;
        if (block.number <= _antiSnipeBlock) {  // 3 blocks after adding liquidity
            if ( _isLP[from] || _bots[from] ) { _markSniper(to); }
        } else { isSafe = !_bots[from]; }
        return isSafe;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from Zero wallet");
        require(_limitCheck(sender, recipient, amount), "Limits exceeded");

        if (!_tradingOpen) { require(_noFees[sender], "Trading not open"); }
        else { require(_antiSnipe(sender, recipient), "Address restricted"); }

        if ( !_inTaxSwap && _isLP[recipient] ) { _swapTax(); }

        uint256 _taxAmount = _calculateTax(sender, recipient, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balances[sender] -= amount;
        _balances[address(this)] += _taxAmount; 
        _balances[recipient] += _transferAmount;
        return true;
    }

    function _checkTradingOpen(address sender) private view returns (bool){
        bool checkResult;
        if ( _tradingOpen ) { checkResult = true; } 
        else if (_noFees[sender]) { checkResult = true; } 
        return checkResult;
    }

    function _limitCheck(address from, address to, uint256 amount) private view returns (bool) {
        bool txSize = true;
        if ( amount > _maxTx && !_noLimits[from] && !_noLimits[to] ) { txSize = false; }
        bool walletSize = true;
        uint256 newBalanceTo = _balances[to] + amount;
        if ( newBalanceTo > _maxWallet && !_noLimits[from] && !_noLimits[to] && !_isLP[to] ) { walletSize = false; } 
        return (txSize && walletSize);
    }

    function _calculateTax(address sender, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        uint256 taxBlock0 = _antiSnipeBlock; //  3 blocks after adding liquidity
        uint256 taxBlock1 = taxBlock0 + 12;   //  15 blocks after adding liquidity
        uint256 taxBlock2 = taxBlock1 + 35;   // 50 blocks after adding liquidity

        if ( _tradingOpen && !_noFees[sender] && !_noFees[recipient] ) { 
            uint8 taxRate;
            if ( _isLP[sender] ) {
                if (block.number > taxBlock2) { taxRate = _buyTaxRate; }
                else if (block.number > taxBlock1) { taxRate = 25; }
                else if (block.number > taxBlock0) { taxRate = 25; }
            } else if ( _isLP[recipient] ) {
                if (block.number > taxBlock2) { taxRate = _sellTaxRate; }
                else if (block.number > taxBlock1) { taxRate = 25; }
                else if (block.number > taxBlock0) { taxRate = 99; }
            }
            taxAmount = amount * taxRate / 100; 
        }
        return taxAmount;
    }

    function _swapTax() private lockTaxSwap {
        uint256 _tokensToSwap = balanceOf(address(this));
        if ( _tokensToSwap >= _taxSwapMin && _tradingOpen ) {
            if ( _tokensToSwap >= _taxSwapMax ) { _tokensToSwap = _taxSwapMax; }        
            _swapTaxTokensForEth(_tokensToSwap);
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { 
                (bool sent,) = _walletMarketing.call{value: _contractETHBalance}("");
            }
        }
    }

    function _swapTaxTokensForEth(uint256 tokenAmount) private {
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _primarySwapRouter.WETH();
        _primarySwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function airdrop(address[] calldata addresses, uint256[] calldata tokenAmounts) external onlyOwner {
        require(addresses.length <= 250,"More than 250 wallets");
        require(addresses.length == tokenAmounts.length,"List length mismatch");

        uint256 airdropTotal = 0;
        for(uint i=0; i < addresses.length; i++){
            airdropTotal += (tokenAmounts[i] * 10**_decimals);
        }
        require(_balances[msg.sender] >= airdropTotal, "Token balance too low");

        for(uint i=0; i < addresses.length; i++){
            _balances[msg.sender] -= (tokenAmounts[i] * 10**_decimals);
            _balances[addresses[i]] += (tokenAmounts[i] * 10**_decimals);
            emit Transfer(msg.sender, addresses[i], (tokenAmounts[i] * 10**_decimals) );       
        }

        emit TokensAirdropped(addresses.length, airdropTotal);
    }

    function blacklistBots(address[] calldata addresses, bool blacklisted) external onlyOwner {
        for(uint i=0; i < addresses.length; i++){
            require(!_isLP[addresses[i]] && addresses[i] != _swapRouterAddress);
            _bots[addresses[i]] = blacklisted;
        }
    }

    function setLimits(uint16 maxTxPermille, uint16 maxWalletPermille) external onlyOwner {
        uint256 newMaxTx = _totalSupply * maxTxPermille / 1000;
        uint256 newMaxWallet = _totalSupply * maxWalletPermille / 1000; 
        require(newMaxTx >= _maxTx && newMaxWallet >= _maxWallet, "Cannot decrease limits");
        _maxTx = newMaxTx;
        _maxWallet = newMaxWallet;
    }

    function setTaxRates(uint8 taxBuyRate, uint8 taxSellRate) external onlyOwner {
        _buyTaxRate = taxBuyRate;
        _sellTaxRate = taxSellRate;
    }

    function setTaxWallet(address payable walletMarketing) external onlyOwner {
        require(!_isLP[walletMarketing] && walletMarketing != _swapRouterAddress && walletMarketing != address(this) && walletMarketing != address(0) );
        _noFees[walletMarketing] = true;
        _noLimits[walletMarketing] = true;
        _walletMarketing = walletMarketing;
    }
}


interface IUniswapV2Factory { 
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}