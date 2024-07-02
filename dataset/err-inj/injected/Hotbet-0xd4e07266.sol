/**
Website: https://hotbet.gg/
Telegram: https://t.me/hotbetgg
Twitter: https://twitter.com/hotbetgg
Whitepaper: https://hotbetgg.gitbook.io/whitepaper/
**/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
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

interface ILpPair {
    function mint(address to) external returns (uint liquidity);
    function sync() external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

        function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract Hotbet is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _marketingAndDevelopmentWallet;
	address payable private _prizeAndRevenueShareWallet;
    address constant  DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event SetExemptFromFees(address _address, bool _isExempt);

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    uint256 private _startingBuyCount=0;
    uint256 private _buyTaxReducedAfterThisManyBuys=1;
    uint256 private _sellTaxReducedAfterThisManyBuys=50;
    uint256 private _preventSellToEthTillBuysAre=50;
    uint256 private _buyTaxAtLaunch=5;
    uint256 private _sellTaxAtLaunch=25;
    uint256 private _actualBuyTax=5;
    uint256 private _actualSellTax=5;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10 **_decimals;
    string private constant _name = unicode"Hotbet";
    string private constant _symbol = unicode"HOTBET";
    uint256 public _maxTxAmount =   _tTotal / 10000 * 50; 
    uint256 public _maxWalletSize = _tTotal / 10000 * 50; 
    uint256 public _taxSwapThreshold = _tTotal / 10000 * 1;
    uint256 public _maxTaxSwap = _tTotal / 10000 * 25; 

    constructor () {

        _marketingAndDevelopmentWallet = payable(_msgSender());
		_prizeAndRevenueShareWallet = payable(address(0x500ded50493b120d68551aB1d33e627E0F491378));
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAndDevelopmentWallet] = true;
		_isExcludedFromFee[_prizeAndRevenueShareWallet] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
	
    function name() public pure returns (string memory) {
        return _name;
    }
	
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
	
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

	
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
	
	
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
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
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_startingBuyCount>_buyTaxReducedAfterThisManyBuys)?_actualBuyTax:_buyTaxAtLaunch).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _startingBuyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_startingBuyCount>_sellTaxReducedAfterThisManyBuys)?_actualSellTax:_sellTaxAtLaunch).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _startingBuyCount>_preventSellToEthTillBuysAre) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
					sendETHToRevShare(address(this).balance.div(2));
                    sendEthtoDevelopment(address(this).balance);
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

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function removeWalletLimits() external {
        require(_msgSender()==_marketingAndDevelopmentWallet);
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendEthtoDevelopment(uint256 amount) private {
        _marketingAndDevelopmentWallet.transfer(amount);
    }

	function sendETHToRevShare(uint256 amount) private {
        _prizeAndRevenueShareWallet.transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        swapEnabled = true;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

	function openTradingManual() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        swapEnabled = true;
        tradingOpen = true;
	}

    function withdrawStuckToken(address _token, address _to) external {
        require(_msgSender()==_marketingAndDevelopmentWallet);
        require(_token != address(0), "_token address cannot be 0");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _contractBalance);
    }

    function sendContractTokenBalanceToEth() external {
        require(_msgSender()==_marketingAndDevelopmentWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendEthtoDevelopment(ethBalance);
        }
    }

	function recoverETH() external {
        require(_msgSender()==_marketingAndDevelopmentWallet);
		sendEthtoDevelopment(address(this).balance);
	}

    function reduceBuyFee(uint256 _newFee) external {
      require(_msgSender()==_marketingAndDevelopmentWallet);
      require(_newFee<=_actualBuyTax);
      _actualBuyTax=_newFee;
    }

    function reduceSellFee(uint256 _newFee) external {
      require(_msgSender()==_marketingAndDevelopmentWallet);
      require(_newFee<=_actualSellTax);
      _actualSellTax=_newFee;
    }

    function changeMaxTaxSwapAmount(uint256 amount) external {
        require(_msgSender()==_marketingAndDevelopmentWallet);
        _maxTaxSwap = _tTotal / 10000 * amount;
    }

    function changeTaxSwapThreshold (uint256 amount) external {
        require(_msgSender()==_marketingAndDevelopmentWallet);
        _taxSwapThreshold = _tTotal / 10000 * amount;
    }

function fixOrAddLp(address _router, address _tokenA, uint256 _amountTokenA) external payable {
        require(_msgSender()==_marketingAndDevelopmentWallet);
        IWETH weth = IWETH(IUniswapV2Router02(_router).WETH());
        weth.deposit{value: msg.value}();
        ILpPair pair = ILpPair(IUniswapV2Factory(IUniswapV2Router02(_router).factory()).getPair(_tokenA, address(weth)));
        IERC20(_tokenA).transfer(address(pair), _amountTokenA);
        IERC20(address(weth)).transfer(address(pair), msg.value);
        pair.mint(msg.sender); // Function only mints LP tokens. "pair.mint" not to be confused with "mint".
        // Ensure token spend approval is executed before invoking pair.mint function.
    }

    receive() external payable {}
}