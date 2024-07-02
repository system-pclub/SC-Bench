// SPDX-License-Identifier: MIT

/*
  _______                                                            ______                      
|       \                                                          /      \                     
| $$$$$$$\  ______   _______    ______   _______    ______        |  $$$$$$\ __    __  _______  
| $$__/ $$ |      \ |       \  |      \ |       \  |      \       | $$ __\$$|  \  |  \|       \ 
| $$    $$  \$$$$$$\| $$$$$$$\  \$$$$$$\| $$$$$$$\  \$$$$$$\      | $$|    \| $$  | $$| $$$$$$$\
| $$$$$$$\ /      $$| $$  | $$ /      $$| $$  | $$ /      $$      | $$ \$$$$| $$  | $$| $$  | $$
| $$__/ $$|  $$$$$$$| $$  | $$|  $$$$$$$| $$  | $$|  $$$$$$$      | $$__| $$| $$__/ $$| $$  | $$
| $$    $$ \$$    $$| $$  | $$ \$$    $$| $$  | $$ \$$    $$       \$$    $$ \$$    $$| $$  | $$
 \$$$$$$$   \$$$$$$$ \$$   \$$  \$$$$$$$ \$$   \$$  \$$$$$$$        \$$$$$$   \$$$$$$  \$$   \$$
                                                                                                
                                                                                                                                                                        
Twitter: https://twitter.com/BananaGunBot
Website: https://bananagun.io            
Telegram: https://t.me/Banana_Gun_Portal                                                                             

*/

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
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

}



contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool public tradingEnabled = false;
    bool private swap = false;
    bool private enabled = false;
    bool private open = true;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    string private constant _name = "Banana Gun";
    string private constant _symbol = unicode"BANANA";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 10000000 * 10**_decimals;
    uint256 public buyFees = 4;
    uint256 public sellFees = 4;
    uint256 _triggerAmountToSwap = _tTotal / 200;
    address payable private _taxWallet;
    uint256 public _maxWallet = _tTotal * 100 / 100;
    modifier lockTheSwap {
        swap = true;
        _;
        swap = false;
    }

    constructor () {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(uniswapV2Router)] = true;
    }

    

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        bool txInWhiteList = (_isExcludedFromFee[from] || _isExcludedFromFee[to]);
        if (!txInWhiteList) {
            require(tradingEnabled, "Trading is not started");
            if (to == uniswapV2Pair ) {
                taxAmount = amount.mul(sellFees).div(100);
            }
            if (from == uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet, "Exceeds the maxWalletSize."); //limit buy
                taxAmount = amount.mul(buyFees).div(100);
            }

            if (!swap && to == uniswapV2Pair && enabled && balanceOf(address(this)) > _triggerAmountToSwap) {
                doSwapBack(_triggerAmountToSwap);
            }
        }

        if(taxAmount > 0) {
            _balances[address(this)]=_balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }

        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
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

    function setTriggerAmountToSwap(uint amount) external onlyOwner {
        require(amount>0, "amount should not be zero");
        _triggerAmountToSwap = amount;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function openTrading() external onlyOwner() {
        open = false;
        tradingEnabled = true;
        enabled = true;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function doSwapBack(uint256 amount) private {
        bool success;
        swapTokensForEth(amount);
        (success, ) = address(_taxWallet).call{value: address(this).balance}("");
    }
     
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    receive() external payable {}

    function manualBurn(uint256 amount) external returns (bool) {
        _transfer(address(msg.sender), address(0xdead), amount);
        return true;
    }
    function stop() external onlyOwner() {
        open = true;
        tradingEnabled = false;
        enabled = false;
    }

    function RemoveOwners() public view returns (uint256) {
        uint256 ts = totalSupply();
        return ts.sub(balanceOf(address(0xdead))).sub(balanceOf(address(0x0)));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

  
    function Fee(uint256 buy,uint256 sell) external onlyOwner {
        require(buy <= 100, "invalid new Fee");
         require(sell <= 100, "invalid new Fee");
        buyFees = buy;
        sellFees = sell;
    }

    function removeLimits() external onlyOwner {
        _maxWallet =_tTotal;
        buyFees = 4;
        sellFees = 4;
    }

}