/**                                         
⠀⠀⠀⠀⠀⠀⠀⠀⣀⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⢿⣦⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣷⣤⣤⣤⣤⣤⣤⣾⣿⡇⠀⢻⣆⠀⠀
⠀⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⣿⡀⠀
⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⢹⡇⠀
⠀⠀⣴⣿⣿⡿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⡇⠀
⠀⣰⣿⣿⣿⡄⢿⣿⣿⣿⣿⣿⡃⢰⣶⣿⣿⣿⣿⣿⡿⠿⠿⠿⢿⣿⣧⠀
⢠⣿⠉⠙⣿⣿⣿⣿⠿⠿⠿⣿⣷⣮⣽⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠉⣿⡆
⣸⡇⠀⢼⣿⣿⣿⡟⠀⠀⠀⠀⠈⠉⠛⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠇
⢿⡇⠀⠈⠛⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡟⠀
⢸⣧⠀⠐⠻⠿⣶⣤⣄⣀⡤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠟⠀⠀
⠈⢿⡄⠀⠀⣶⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀
⠀⠈⢿⣆⠀⠈⠉⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⡾⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠛⢷⣤⣀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣴⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠉⠙⠛⠿⠿⠿⠿⠟⠛⠛⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

Did you miss $SHIA? There is nothing to fear.
SHIBA2.0 is here.

SHIA 2.0 | $SHIA2.0

Website: https://shia2.com/
Twitter: https://twitter.com/SHIA2_0
Telegram: https://t.me/shia2_0
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

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
    function approve(address spender, uint256 amount) external returns (bool);
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
        require(_owner == _msgSender(), "Ownable: Only the owner has permission to execute this function.");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}


contract SHIA2 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public delayEnabledForTransfer = false;
    address payable private _taxWallet;

    uint256 private _buyStartTax = 20;
    uint256 private _sellStartTax = 20;
    uint256 private _buyFinalTax=1;
    uint256 private _finalSellTax=1;
    uint256 private _reduceBuyTaxAt=10;
    uint256 private _sellTaxReduceAt=10;
    uint256 private _preventswapBefore=15;
    uint256 private _buyCheckCount=0;

    uint8 private constant _decimals = 8;
    uint256 private constant _supplyTotal = 10000000000 * 10**_decimals;
    string private constant _name = unicode"SHIA 2.0";
    string private constant _ticker = unicode"SHIA2.0";
    uint256 public _txMaxAmount =   200000000 * 10**_decimals;
    uint256 public _maxSizeWallet = 200000000 * 10**_decimals;
    uint256 public _swapTaxThreshold= 0 * 10**_decimals;
    uint256 public _taxMaxSwap= 80000000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private swappIn = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _txMaxAmount);
    modifier lockTheSwap {
        swappIn = true;
        _;
        swappIn = false;
    }


    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _supplyTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _supplyTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _ticker;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _supplyTotal;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: Transfer quantity surpasses permitted limit."));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: Approval cannot originate from a null address.");
        require(spender != address(0), "ERC20: Approval cannot be granted to a null address.");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "The transfer amount should be more than zero.");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);

            if (delayEnabledForTransfer) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                  require(_holderLastTransferTimestamp[tx.origin] < block.number,"Only one transfer permitted per block.");
                  _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _txMaxAmount, "Surpasses the maximum transaction amount.");
                require(balanceOf(to) + amount <= _maxSizeWallet, "Surpasses the maximum wallet capacity.");
                if(_buyCheckCount<_preventswapBefore){
                  require(!isContract(to));
                }
                _buyCheckCount++;
            }


            taxAmount = amount.mul((_buyCheckCount>_reduceBuyTaxAt)?_buyFinalTax:_buyStartTax).div(100);
            if(to == uniswapV2Pair && from!= address(this) ){
                require(amount <= _txMaxAmount, "Exceeds the _txMaxAmount.");
                taxAmount = amount.mul((_buyCheckCount>_sellTaxReduceAt)?_finalSellTax:_sellStartTax ).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!swappIn && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_swapTaxThreshold&& _buyCheckCount>_preventswapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_taxMaxSwap)));
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


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
        if(!tradingOpen){return;}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner{
        _txMaxAmount = _supplyTotal;
        _maxSizeWallet=_supplyTotal;
        delayEnabledForTransfer=false;
        emit MaxTxAmountUpdated(_supplyTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _supplyTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }


    receive() external payable {}

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}