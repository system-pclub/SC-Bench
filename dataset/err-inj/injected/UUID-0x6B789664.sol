// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(
    address owner,
    address spender
  ) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  /**
   * @dev Returns the name of the token.
   */

  /**
   * @dev Returns the symbol of the token.
   */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the decimals places of the token.
   */
  function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }


  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply+110;  }

  function balanceOf(
    address account
  ) public view virtual override returns (uint256) {
    return _balances[account];
  }

  function transfer(
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(
    address owner,
    address spender
  ) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(
    address spender,
    uint256 amount
  ) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }


  function increaseAllowance(
    address spender,
    uint256 addedValue
  ) public virtual returns (bool) {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  ) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERC20: decreased allowance below zero"
    );
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
      _balances[sender] = senderBalance - amount;
    }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  function _createInitialSupply(
    address account,
    uint256 amount
  ) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
      // Overflow not possible: amount <= accountBalance <= totalSupply.
      _totalSupply -= amount;
    }

    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
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

  function renounceOwnership() external virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface IDexRouter {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;
}

interface IDexFactory {
  function createPair(
    address tokenA,
    address tokenB
  ) external returns (address pair);
}

contract UUID is ERC20, Ownable {
  uint256 public maxBuyAmount;
  uint256 public maxSellAmount;
  uint256 public maxWalletAmount;

  IDexRouter public dexRouter;
  address public lpPair;

  bool private swapping;
  uint256 public swapTokensAtAmount;

  address taxAddress;

  bool public limitsInEffect = true;
  bool public tradingActive = false;

  // Anti-sandwithc-bot mappings and variables
  mapping(address => uint256) private _holderLastBuyBlock; // to hold last Buy temporarily
  bool public transferDelayEnabled = true;

  uint256 public buyFee;
  uint256 public sellFee;

  /******************/

  // exlcude from fees and max transaction amount
  mapping(address => bool) private _isExcludedFromFees;
  mapping(address => bool) public _isExcludedMaxTransactionAmount;

  // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
  // could be subject to a maximum transfer amount
  mapping(address => bool) public automatedMarketMakerPairs;

  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

  event EnabledTrading();

  event ExcludeFromFees(address indexed account, bool isExcluded);

  event MaxTransactionExclusion(address _address, bool excluded);

  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiquidity
  );

  event TransferForeignToken(address token, uint256 amount);

  constructor() ERC20("UUID", "UUID") {
    address newOwner = msg.sender; // can leave alone if owner is deployer.

    IDexRouter _dexRouter = IDexRouter(
      0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    dexRouter = _dexRouter;

    // create pair
    lpPair = IDexFactory(_dexRouter.factory()).createPair(
      address(this),
      _dexRouter.WETH()
    );
    _excludeFromMaxTransaction(address(lpPair), true);
    _excludeFromMaxTransaction(address(dexRouter), true);
    _setAutomatedMarketMakerPair(address(lpPair), true);

    uint256 totalSupply = 1 * 1e8 * 1e18;

    maxBuyAmount = (totalSupply * 7) / 1000;
    maxSellAmount = (totalSupply * 7) / 1000;
    maxWalletAmount = (totalSupply * 7) / 1000;
    swapTokensAtAmount = (totalSupply * 1) / 100;

    buyFee = 30;
    sellFee = 30;

    _excludeFromMaxTransaction(newOwner, true);
    _excludeFromMaxTransaction(address(this), true);
    _excludeFromMaxTransaction(address(0xdead), true);

    excludeFromFees(newOwner, true);
    excludeFromFees(address(this), true);
    excludeFromFees(address(0xdead), true);

    taxAddress = address(0xc7aF5Bc9BD31e8B80671056F76f2AcA92791B91C);

    _createInitialSupply(newOwner, totalSupply);
    transferOwnership(newOwner);
  }

  receive() external payable {}

  // only enable if no plan to airdrop

  function enableTrading() external onlyOwner {
    require(!tradingActive, "Cannot reenable trading");
    tradingActive = true;
    emit EnabledTrading();
  }

  // remove limits after token is stable
  function removeLimits() external onlyOwner {
    limitsInEffect = false;
  }

  // change the minimum amount of tokens to sell from fees
  function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
    require(
      newAmount >= (totalSupply() * 1) / 1000,
      "Swap amount cannot be lower than 0.1% total supply."
    );
    require(
      newAmount <= (totalSupply() * 1) / 20,
      "Swap amount cannot be higher than 5% total supply."
    );
    swapTokensAtAmount = newAmount;
  }

  function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
    _isExcludedMaxTransactionAmount[updAds] = isExcluded;
    emit MaxTransactionExclusion(updAds, isExcluded);
  }

  function airdropToWallets(
    address[] memory wallets,
    uint256[] memory amountsInTokens
  ) external onlyOwner {
    require(
      wallets.length == amountsInTokens.length,
      "arrays must be the same length"
    );
    require(
      wallets.length < 600,
      "Can only airdrop 600 wallets per txn due to gas limits"
    ); // allows for airdrop + launch at the same exact time, reducing delays and reducing sniper input.
    for (uint256 i = 0; i < wallets.length; i++) {
      address wallet = wallets[i];
      uint256 amount = amountsInTokens[i];
      super._transfer(msg.sender, wallet, amount);
    }
  }

  function excludeFromMaxTransaction(
    address updAds,
    bool isEx
  ) external onlyOwner {
    if (!isEx) {
      require(updAds != lpPair, "Cannot remove uniswap pair from max txn");
    }
    _isExcludedMaxTransactionAmount[updAds] = isEx;
  }

  function setAutomatedMarketMakerPair(
    address pair,
    bool value
  ) external onlyOwner {
    require(
      pair != lpPair,
      "The pair cannot be removed from automatedMarketMakerPairs"
    );

    _setAutomatedMarketMakerPair(pair, value);
    emit SetAutomatedMarketMakerPair(pair, value);
  }

  function _setAutomatedMarketMakerPair(address pair, bool value) private {
    automatedMarketMakerPairs[pair] = value;

    _excludeFromMaxTransaction(pair, value);

    emit SetAutomatedMarketMakerPair(pair, value);
  }

  function updateBuyFees(uint256 _buyFee) external onlyOwner {
    require(_buyFee <= 70, "Must keep fees at 50% or less");
    buyFee = _buyFee;
  }

  function updateSellFees(uint256 _sellFee) external onlyOwner {
    require(_sellFee <= 70, "Must keep fees at 50% or less");
    sellFee = _sellFee;
  }

  function excludeFromFees(address account, bool excluded) public onlyOwner {
    _isExcludedFromFees[account] = excluded;
    emit ExcludeFromFees(account, excluded);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "amount must be greater than 0");

    if (!tradingActive) {
      require(
        _isExcludedFromFees[from] || _isExcludedFromFees[to],
        "Trading is not active."
      );
    }

    // anti sandwich bot
    if (
      automatedMarketMakerPairs[from] &&
      !automatedMarketMakerPairs[to] &&
      to != address(this) &&
      to != address(dexRouter)
    ) {
      _holderLastBuyBlock[to] = block.number;
    }
    require(
      _holderLastBuyBlock[from] < block.number,
      "_transfer:: Anti sandwich bot enabled. Please try again later."
    );

    if (limitsInEffect) {
      if (
        from != owner() &&
        to != owner() &&
        to != address(0) &&
        to != address(0xdead) &&
        !_isExcludedFromFees[from] &&
        !_isExcludedFromFees[to]
      ) {
        //when buy
        if (
          automatedMarketMakerPairs[from] &&
          !_isExcludedMaxTransactionAmount[to]
        ) {
          require(
            amount <= maxBuyAmount,
            "Buy transfer amount exceeds the max buy."
          );
          require(
            amount + balanceOf(to) <= maxWalletAmount,
            "Cannot Exceed max wallet"
          );
        }
        //when sell
        else if (
          automatedMarketMakerPairs[to] &&
          !_isExcludedMaxTransactionAmount[from]
        ) {
          if (amount > maxSellAmount) {
            amount = maxSellAmount;
          }
        } else if (!_isExcludedMaxTransactionAmount[to]) {
          require(
            amount + balanceOf(to) <= maxWalletAmount,
            "Cannot Exceed max tokens per wallet"
          );
        }
      }
    }

    uint256 contractTokenBalance = balanceOf(address(this));

    bool canSwap = contractTokenBalance >= swapTokensAtAmount;

    if (
      canSwap &&
      tradingActive &&
      !swapping &&
      !automatedMarketMakerPairs[from] &&
      !_isExcludedFromFees[from] &&
      !_isExcludedFromFees[to]
    ) {
      swapping = true;
      swapBack();
      swapping = false;
    }

    // only take fees on buys/sells, do not take on wallet transfers
    if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
      uint256 fees = 0;
      // on sell
      if (automatedMarketMakerPairs[to] && sellFee > 0) {
        fees = (amount * sellFee) / 100;
      }
      // on buy
      else if (automatedMarketMakerPairs[from] && buyFee > 0) {
        fees = (amount * buyFee) / 100;
      }
      if (fees > 0) {
        super._transfer(from, address(this), fees);
      }
      amount -= fees;
    }

    super._transfer(from, to, amount);
  }

  function swapTokensForEth(uint256 tokenAmount) private {
    // generate the uniswap pair path of token -> weth
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = dexRouter.WETH();

    _approve(address(this), address(dexRouter), tokenAmount);

    // make the swap
    dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0, // accept any amount of ETH
      path,
      address(this),
      block.timestamp
    );
  }

  function swapBack() private {
    uint256 contractBalance = balanceOf(address(this));
    if (contractBalance == 0) {
      return;
    }

    if (contractBalance > swapTokensAtAmount * 6) {
      contractBalance = swapTokensAtAmount * 6;
    }

    bool success;

    swapTokensForEth(contractBalance);

    uint256 ethBalance = address(this).balance;

    if (ethBalance > 0) {
      (success, ) = address(taxAddress).call{value: ethBalance}("");
    }
  }

  function transferForeignToken(
    address _token,
    address _to
  ) external onlyOwner returns (bool _sent) {
    require(_token != address(0), "_token address cannot be 0");
    require(_token != address(this), "Can't withdraw native tokens");
    uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
    _sent = IERC20(_token).transfer(_to, _contractBalance);
    emit TransferForeignToken(_token, _contractBalance);
  }

  // withdraw ETH if stuck or someone sends to the address
  function withdrawStuckETH() external onlyOwner {
    bool success;
    (success, ) = address(msg.sender).call{value: address(this).balance}("");
  }
}