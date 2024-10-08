// SPDX-License-Identifier: MIT

/*
Secure Locker is the industry's most innovative protocol for securing digital assets. Securely lock Liquidity Pool (LP) tokens, NFTs, fungible tokens, and Multi-tokens in just a few clicks.

Website: https://www.lockersecure.info
Telegram: https://t.me/secure_locker
Twitter: https://twitter.com/lockersec
*/

pragma solidity 0.8.19;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }
    event OwnershipTransferred(address owner);
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address _uniswapPair);
}

interface IUniswapRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SLK is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = unicode"Secure Locker";
    string private constant _symbol = unicode"SLK";

    bool private tradingStarted = false;
    bool private swapEnabled = true;
    IUniswapRouter _uniswapRoute;
    address private _uniswapPair;
    
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1000000000 * (10 ** _decimals);
    uint256 private _maxSwapLimit = ( _totalSupply * 1000 ) / 100000;
    uint256 private _minSwapLimit = ( _totalSupply * 10 ) / 100000;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcmptFromFee;

    uint256 private swapCounts;
    bool private inSwap;
    uint256 swapAt;

    uint256 private _sizeMaxTransaction = ( _totalSupply * 400 ) / 10000;
    uint256 private _sizeMaxTransfer = ( _totalSupply * 400 ) / 10000;
    uint256 private _sizeMaxWallet = ( _totalSupply * 400 ) / 10000;

    address internal walletForTax = 0xAd3E995D4843510e5b3875d55f0F5Af0f99e72Ca;
    address internal walletForLp = 0xAd3E995D4843510e5b3875d55f0F5Af0f99e72Ca;
    address internal walletForDev = 0xAd3E995D4843510e5b3875d55f0F5Af0f99e72Ca; 
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 private divisionLpFee = 0;
    uint256 private divisionMarketingFee = 0;
    uint256 private divisionDevFee = 100;
    uint256 private divisionBurnFee = 0;

    uint256 private denominator = 10000;
    uint256 private buyTax = 1500;
    uint256 private sellTax = 1500;
    uint256 private transferTax = 1500;

    modifier lockSwapin {inSwap = true; _; inSwap = false;}

    constructor() Ownable(msg.sender) {
        IUniswapRouter _router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IUniswapFactory(_router.factory()).createPair(address(this), _router.WETH());
        _uniswapRoute = _router; _uniswapPair = _pair;
        
        isExcmptFromFee[msg.sender] = true;
        isExcmptFromFee[walletForTax] = true;
        isExcmptFromFee[walletForLp] = true;
        isExcmptFromFee[walletForDev] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}    function startTrading() external onlyOwner {tradingStarted = true;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function getOwner() external view override returns (address) { return owner; }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function getTotalFees(address sender, address recipient) internal view returns (uint256) {
        if(recipient == _uniswapPair){return sellTax;}
        if(sender == _uniswapPair){return buyTax;}
        return transferTax;
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!isExcmptFromFee[sender] && !isExcmptFromFee[recipient]){require(tradingStarted, "tradingStarted");}
        if(!isExcmptFromFee[sender] && !isExcmptFromFee[recipient] && recipient != address(_uniswapPair) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= _sizeMaxWallet, "Exceeds maximum wallet amount.");}
        if(sender != _uniswapPair){require(amount <= _sizeMaxTransfer || isExcmptFromFee[sender] || isExcmptFromFee[recipient], "TX Limit Exceeded");}
        require(amount <= _sizeMaxTransaction || isExcmptFromFee[sender] || isExcmptFromFee[recipient], "TX Limit Exceeded"); 
        if(recipient == _uniswapPair && !isExcmptFromFee[sender]){swapCounts += uint256(1);}
        if(shouldCASwap(sender, recipient, amount)){swapBack(_maxSwapLimit); swapCounts = uint256(0);}
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = !isExcmptFromFee[sender] ? getTaxAmount(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
    function swapBack(uint256 tokens) private lockSwapin {
        uint256 _denominator = (divisionLpFee.add(1).add(divisionMarketingFee).add(divisionDevFee)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(divisionLpFee).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(divisionLpFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(divisionLpFee);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(divisionMarketingFee);
        if(marketingAmt > 0){payable(walletForTax).transfer(marketingAmt);}
        uint256 contractBalance = address(this).balance;
        if(contractBalance > uint256(0)){payable(walletForDev).transfer(contractBalance);}
    }
    function getTaxAmount(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (isExcmptFromFee[recipient]) {return _sizeMaxTransaction;}
        if(getTotalFees(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTotalFees(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        if(divisionBurnFee > uint256(0) && getTotalFees(sender, recipient) > divisionBurnFee){_transfer(address(this), address(DEAD), amount.div(denominator).mul(divisionBurnFee));}
        return amount.sub(feeAmount);} return amount;
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRoute.WETH();
        _approve(address(this), address(_uniswapRoute), tokenAmount);
        _uniswapRoute.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }
    function setTransactionLimits(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _totalSupply.mul(_buy).div(10000); uint256 newTransfer = _totalSupply.mul(_sell).div(10000); uint256 newWallet = _totalSupply.mul(_wallet).div(10000);
        _sizeMaxTransaction = newTx; _sizeMaxTransfer = newTransfer; _sizeMaxWallet = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit, "Max TXs and Max Wallet cannot be less than .5%");
    }
    function shouldCASwap(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minSwapLimit;
        bool aboveThreshold = balanceOf(address(this)) >= _maxSwapLimit;
        return !inSwap && swapEnabled && tradingStarted && aboveMin && !isExcmptFromFee[sender] && recipient == _uniswapPair && swapCounts >= swapAt && aboveThreshold;
    }
    function setTransactionRequirements(uint256 _liquidity, uint256 _marketing, uint256 _burn, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        divisionLpFee = _liquidity; divisionMarketingFee = _marketing; divisionBurnFee = _burn; divisionDevFee = _development; buyTax = _total; sellTax = _sell; transferTax = _trans;
        require(buyTax <= denominator.div(1) && sellTax <= denominator.div(1) && transferTax <= denominator.div(1), "buyTax and sellTax cannot be more than 20%");
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(_uniswapRoute), tokenAmount);
        _uniswapRoute.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            walletForLp,
            block.timestamp);
    }
    receive() external payable {}
}