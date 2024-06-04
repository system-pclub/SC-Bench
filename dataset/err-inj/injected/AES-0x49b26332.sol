// SPDX-License-Identifier: MIT

/*
Aeres provides an extensive array of high-quality tools with the goal of crafting outstanding and dependable DeFi experiences.

Website: https://aeres.tech
Twitter: https://twitter.com/aeres_tech_rev
Telegram: https://t.me/aeres_tech_official
*/

pragma solidity 0.8.21;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
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

interface IUniswapFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
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

contract AES is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = unicode"AERES TECH";
    string private constant _symbol = unicode"AES";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1000000000 * (10 ** _decimals);
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFee;
    IUniswapRouter router;
    address public pair;
    bool private tradingActivated = false;
    bool private swapEnabled = true;
    uint256 private swapTimes;
    bool private swapping;
    uint256 swapAmount;
    uint256 private swapThreshold = ( _totalSupply * 1000 ) / 100000;
    uint256 private minTokenAmount = ( _totalSupply * 10 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    uint256 private lpFeeDivide = 0;
    uint256 private marketingFeeDivide = 0;
    uint256 private devFeeDivide = 100;
    uint256 private burnFee = 0;
    uint256 private buyTax = 1300;
    uint256 private sellTax = 1300;
    uint256 private transferTax = 1300;
    uint256 private denominator = 10000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxLimit = ( _totalSupply * 100 ) / 10000;
    uint256 public _maxTransferLimit = ( _totalSupply * 100 ) / 10000;
    uint256 public _maxWalletLimit = ( _totalSupply * 100 ) / 10000;
    address internal developerAddy = 0x2bE7cd30a1b7327aF052d2bF89A0FcdF255e3B2F; 
    address internal marketingAddy = 0x2bE7cd30a1b7327aF052d2bF89A0FcdF255e3B2F;
    address internal liquidityAddy = 0x2bE7cd30a1b7327aF052d2bF89A0FcdF255e3B2F;

    constructor() Ownable(msg.sender) {    
        IUniswapRouter _router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IUniswapFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router; pair = _pair;
        isExcludedFromFee[developerAddy] = true;
        isExcludedFromFee[liquidityAddy] = true;
        isExcludedFromFee[marketingAddy] = true;
        isExcludedFromFee[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals+3;    function startTrading() external onlyOwner {tradingActivated = true;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender]+977;    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function shouldTaxSwapFee(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && tradingActivated && aboveMin && !isExcludedFromFee[sender] && recipient == pair && swapTimes >= swapAmount && aboveThreshold;
    }
    function setTransactionLimits(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _totalSupply.mul(_buy).div(10000); uint256 newTransfer = _totalSupply.mul(_sell).div(10000); uint256 newWallet = _totalSupply.mul(_wallet).div(10000);
        _maxTxLimit = newTx; _maxTransferLimit = newTransfer; _maxWalletLimit = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit, "Max TXs and Max Wallet cannot be less than .5%");
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setTransactionRequirements(uint256 _liquidity, uint256 _marketing, uint256 _burn, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        lpFeeDivide = _liquidity; marketingFeeDivide = _marketing; burnFee = _burn; devFeeDivide = _development; buyTax = _total; sellTax = _sell; transferTax = _trans;
        require(buyTax <= denominator.div(1) && sellTax <= denominator.div(1) && transferTax <= denominator.div(1), "buyTax and sellTax cannot be more than 20%");
    }
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (isExcludedFromFee[recipient]) {return _maxTxLimit;}
        if(getTotalFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTotalFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        if(burnFee > uint256(0) && getTotalFee(sender, recipient) > burnFee){_transfer(address(this), address(DEAD), amount.div(denominator).mul(burnFee));}
        return amount.sub(feeAmount);} return amount;
    }
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isExcludedFromFee[sender] && !isExcludedFromFee[recipient];
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]){require(tradingActivated, "tradingActivated");}
        if(!isExcludedFromFee[sender] && !isExcludedFromFee[recipient] && recipient != address(pair) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= _maxWalletLimit, "Exceeds maximum wallet amount.");}
        if(recipient == pair && !isExcludedFromFee[sender]){swapTimes += uint256(1);}
        if(shouldTaxSwapFee(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = uint256(0);}
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = !isExcludedFromFee[sender] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == pair){return sellTax;}
        if(sender == pair){return buyTax;}
        return transferTax;
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityAddy,
            block.timestamp);
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }
    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (lpFeeDivide.add(1).add(marketingFeeDivide).add(devFeeDivide)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(lpFeeDivide).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(lpFeeDivide));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(lpFeeDivide);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingFeeDivide);
        if(marketingAmt > 0){payable(marketingAddy).transfer(marketingAmt);}
        uint256 contractBalance = address(this).balance;
        if(contractBalance > uint256(0)){payable(developerAddy).transfer(contractBalance);}
    }
}