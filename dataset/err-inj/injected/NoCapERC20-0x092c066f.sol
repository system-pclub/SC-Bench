/*

███╗   ██╗ ██████╗      ██████╗ █████╗ ██████╗ 
████╗  ██║██╔═══██╗    ██╔════╝██╔══██╗██╔══██╗
██╔██╗ ██║██║   ██║    ██║     ███████║██████╔╝
██║╚██╗██║██║   ██║    ██║     ██╔══██║██╔═══╝ 
██║ ╚████║╚██████╔╝    ╚██████╗██║  ██║██║     
╚═╝  ╚═══╝ ╚═════╝      ╚═════╝╚═╝  ╚═╝╚═╝                                        

Website: https://nocap.cool
Telegram: https://t.me/NCAP_Portal
Twitter: https://twitter.com/NoCapERC20

 ██████╗ ███╗   ██╗ ██████╗     ███████╗██████╗ ███████╗██████╗ 
██╔═══██╗████╗  ██║██╔════╝     ██╔════╝██╔══██╗██╔════╝██╔══██╗
██║   ██║██╔██╗ ██║██║  ███╗    █████╗  ██████╔╝█████╗  ██████╔╝
██║   ██║██║╚██╗██║██║   ██║    ██╔══╝  ██╔══██╗██╔══╝  ██╔══██╗
╚██████╔╝██║ ╚████║╚██████╔╝    ██║     ██║  ██║██║     ██║  ██║
 ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝     ╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝
                                                                                     
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transfer(address recipient, uint256 amount) external returns (bool);
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


contract NoCapERC20 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => bool) private cappinBots;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    bool public delayTransferEnabled = false;
    
    string private constant _name = unicode"No Cap";
    string private constant _symbol = unicode"NCAP";

    uint8 private constant _decimals = 8;
    uint256 private constant _totalSupply = 100000000 * 10**_decimals;
    uint256 public _maxTxAmount = 1000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000 * 10**_decimals;
    uint256 public _taxSwapThreshold=  0 * 10**_decimals;
    uint256 public _maxTaxSwap = 987654 * 10**_decimals;

    uint256 private _beginningBuyTax=20;
    uint256 private _beginningSellTax=45;
    uint256 private _reduceBuyTaxAt=125;
    uint256 private _reduceSellTaxAt=250;
    uint256 private _finalBuyTax=2;
    uint256 private _finalSellTax=2;
    uint256 private _preventSwapBefore=100;
    uint256 private _buyCount=0;

    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _lastTrsTime;

    address payable private _noCapTrust;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private enabledSwap = false;


    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _noCapTrust = payable(_msgSender());
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_noCapTrust] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }


    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account]+336;    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(!cappinBots[from] && !cappinBots[to]);

            if (delayTransferEnabled) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                  require(_lastTrsTime[tx.origin] < block.number,"Transfers are limited to one per block.");
                  _lastTrsTime[tx.origin] = block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                if(_buyCount<_preventSwapBefore){
                  require(!isContract(to));
                }
                _buyCount++;
            }

            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_beginningBuyTax).div(100);
            if(to == uniswapV2Pair && from!= address(this) ){
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_beginningSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && enabledSwap && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
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
        _maxTxAmount = _totalSupply;
        _maxWalletSize=_totalSupply;
        delayTransferEnabled=false;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        enabledSwap = true;
        tradingOpen = true;
    }

    function finalizeBuyTaxes() external {
      require(_msgSender()==_noCapTrust);
      _beginningBuyTax=_finalBuyTax;
    }

    function finalizeSellTaxes() external {
      require(_msgSender()==_noCapTrust);
      _beginningSellTax=_finalSellTax;
    }

    function sendETHToFee(uint256 amount) private {
        _noCapTrust.transfer(amount);
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
        require(_msgSender()==_noCapTrust);
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