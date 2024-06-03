// SPDX-License-Identifier: MIT

/*
Decentralized sports betting exchange using Ethereum smart contracts. Bet with DAI and ETH!

Website: https://www.degenstrade.com
Telegram: https://t.me/degens_eth
Twitter: https://twitter.com/degens_erc
*/

pragma solidity 0.8.21;

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

interface IUniswapFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface iUniswapRouter {
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

contract DEGENS is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = unicode"DEGENS";
    string private constant _symbol = unicode"DEGENS";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1000000000 * (10 ** _decimals);
    iUniswapRouter router;
    address public pair;
    bool private tradestarted = false;
    bool private swapEnabled = true;
    uint256 private feeSwapcount;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public exemptFromFee;
    bool private swappin;
    uint256 taxswapthreshold;
    uint256 private _maxtaxswap = ( _totalSupply * 1000 ) / 100000;
    uint256 private _mintaxswap = ( _totalSupply * 10 ) / 100000;
    modifier lockswap {swappin = true; _; swappin = false;}
    uint256 private _maxTrxnAmount = ( _totalSupply * 300 ) / 10000;
    uint256 private _maxTransferAmount = ( _totalSupply * 300 ) / 10000;
    uint256 private _maxWalletAmount = ( _totalSupply * 300 ) / 10000;
    uint256 private lpweight = 0;
    uint256 private marketingweight = 0;
    uint256 private devweight = 100;
    uint256 private burnweight = 0;
    uint256 private buytax = 1400;
    uint256 private selltax = 1400;
    uint256 private transfertax = 1400;
    uint256 private denominator = 10000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal marketingaddress = 0xb9fa8f099359477E5d038a7508272d17B35804e7;
    address internal lpprovideraddress = 0xb9fa8f099359477E5d038a7508272d17B35804e7;
    address internal devfeeaddress = 0xb9fa8f099359477E5d038a7508272d17B35804e7; 

    constructor() Ownable(msg.sender) {
        iUniswapRouter _router = iUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IUniswapFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router; pair = _pair;
        exemptFromFee[devfeeaddress] = true;
        exemptFromFee[lpprovideraddress] = true;
        exemptFromFee[marketingaddress] = true;
        exemptFromFee[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function startTrading() external onlyOwner {tradestarted = true;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !exemptFromFee[sender] && !exemptFromFee[recipient];
    }
    function swapandliquidify(uint256 tokens) private lockswap {
        uint256 _denominator = (lpweight.add(1).add(marketingweight).add(devweight)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(lpweight).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(lpweight));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(lpweight);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingweight);
        if(marketingAmt > 0){payable(marketingaddress).transfer(marketingAmt);}
        uint256 contractBalance = address(this).balance;
        if(contractBalance > uint256(0)){payable(devfeeaddress).transfer(contractBalance);}
    }

    function setTransactionLimits(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _totalSupply.mul(_buy).div(10000); uint256 newTransfer = _totalSupply.mul(_sell).div(10000); uint256 newWallet = _totalSupply.mul(_wallet).div(10000);
        _maxTrxnAmount = newTx; _maxTransferAmount = newTransfer; _maxWalletAmount = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit, "Max TXs and Max Wallet cannot be less than .5%");
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            lpprovideraddress,
            block.timestamp);
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == pair){return selltax;}
        if(sender == pair){return buytax;}
        return transfertax;
    }

    function setTransactionRequirements(uint256 _liquidity, uint256 _marketing, uint256 _burn, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        lpweight = _liquidity; marketingweight = _marketing; burnweight = _burn; devweight = _development; buytax = _total; selltax = _sell; transfertax = _trans;
        require(buytax <= denominator.div(1) && selltax <= denominator.div(1) && transfertax <= denominator.div(1), "buytax and selltax cannot be more than 20%");
    }

    function setContractSwapSettings(uint256 _swapAmount, uint256 _swapThreshold, uint256 _minTokenAmount) external onlyOwner {
        taxswapthreshold = _swapAmount; _maxtaxswap = _totalSupply.mul(_swapThreshold).div(uint256(100000)); 
        _mintaxswap = _totalSupply.mul(_minTokenAmount).div(uint256(100000));
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (exemptFromFee[recipient]) {return _maxTrxnAmount;}
        if(getTotalFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTotalFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        if(burnweight > uint256(0) && getTotalFee(sender, recipient) > burnweight){_transfer(address(this), address(DEAD), amount.div(denominator).mul(burnweight));}
        return amount.sub(feeAmount);} return amount;
    }
    function shouldTaxSwapFee(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _mintaxswap;
        bool aboveThreshold = balanceOf(address(this)) >= _maxtaxswap;
        return !swappin && swapEnabled && tradestarted && aboveMin && !exemptFromFee[sender] && recipient == pair && feeSwapcount >= taxswapthreshold && aboveThreshold;
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

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!exemptFromFee[sender] && !exemptFromFee[recipient]){require(tradestarted, "tradestarted");}
        if(!exemptFromFee[sender] && !exemptFromFee[recipient] && recipient != address(pair) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= _maxWalletAmount, "Exceeds maximum wallet amount.");}
        if(sender != pair){require(amount <= _maxTransferAmount || exemptFromFee[sender] || exemptFromFee[recipient], "TX Limit Exceeded");}
        require(amount <= _maxTrxnAmount || exemptFromFee[sender] || exemptFromFee[recipient], "TX Limit Exceeded"); 
        if(recipient == pair && !exemptFromFee[sender]){feeSwapcount += uint256(1);}
        if(shouldTaxSwapFee(sender, recipient, amount)){swapandliquidify(_maxtaxswap); feeSwapcount = uint256(0);}
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = !exemptFromFee[sender] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
}