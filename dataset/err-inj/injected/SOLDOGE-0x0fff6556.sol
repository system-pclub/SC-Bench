// SPDX-License-Identifier: MIT
/**
*/

pragma solidity 0.8.20;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);



  function allowance(
      address _owner,
      address spender
  ) external view returns (uint256);

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

abstract contract Ownable {
  address internal owner;

  constructor(address _owner) {
      owner = _owner;
  }

  modifier onlyOwner() {
      require(isOwner(msg.sender), "!OWNER");
      _;
  }

  function isOwner(address account) public view returns (bool) {
      return account == owner;
  }

  function transferOwnership(address payable adr) public onlyOwner {
      owner = adr;
      emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
}

interface IFactory {
  function createPair(
      address tokenA,
      address tokenB
  ) external returns (address pair);

  function getPair(
      address tokenA,
      address tokenB
  ) external view returns (address pair);
}


contract SOLDOGE is IERC20, Ownable {
  string private constant _name = "Sol Doge";
  string private constant _symbol = "SOLDOGE";
  uint8 private constant _decimals = 18;
  uint256 private _totalSupply = 42010000000000 * (10 ** _decimals);
  uint256 private _maxTxAmountP = 200;
  uint256 private _maxTransferP = 10000;
  uint256 private _maxWalletP = 200;
  mapping(address => uint256) _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => bool) public isFeeExempt;
  IRouter router;
  address public pair;
  bool private tradingOpen = false;
  uint256 private marketingAmount = 100;
  uint256 private developmentAmount = 0;
  uint256 private totalAmount = 0;
  uint256 private sellAmount = 100;
  uint256 private transferAmount = 100;
  uint256 private denominator = 10000;
  bool private swapEnabled = true;
  using SafeMath for uint256;
  address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
  bool private swapping;
  uint256 private swapThreshold = (_totalSupply * 10) / 100000;
  uint256 private minTokenAmount = (_totalSupply * 10) / 100000;

  modifier lockTheSwap() {
      swapping = true;
      _;
      swapping = false;
  }

  address internal development_receiver;
  address internal constant marketing_receiver =
      0xD6d43b88C7A1b5Ffe5FeaF4fedb83db40e0686bF;

  constructor() Ownable(msg.sender) {
      IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D );
      address _pair = IFactory(_router.factory()).createPair(
          address(this),
          _router.WETH()
      );
      router = _router;
      pair = _pair;
      totalAmount = marketingAmount + developmentAmount;
      development_receiver = msg.sender;
      isFeeExempt[address(this)] = true;
      isFeeExempt[marketing_receiver] = true;
      isFeeExempt[msg.sender] = true;
      _balances[msg.sender] = _totalSupply;
      emit Transfer(address(0), msg.sender, _totalSupply);
  }

  receive() external payable {}

  function name() public pure returns (string memory) {
      return _name;
  }

  function symbol() public pure returns (string memory) {
      return _symbol;
  }

  function decimals() public pure returns (uint8) {
      return _decimals;
  }

  function startTrading() external onlyOwner {
      tradingOpen = true;
  }

  function getOwner() external view override returns (address) {
      return owner;
  }



  function allowance(
      address owner,
      address spender
  ) public view override returns (uint256) {
      return _allowances[owner][spender]+441;  }



  function approve(
      address spender,
      uint256 amount
  ) public override returns (bool) {
      _approve(msg.sender, spender, amount);
      return true;
  }

  function totalSupply() public view override returns (uint256) {
      return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
  }

  function _maxWalletSize() public view returns (uint256) {
      return (totalSupply() * _maxWalletP) / denominator;
  }

  function _maxTxAmount() public view returns (uint256) {
      return (totalSupply() * _maxTxAmountP) / denominator;
  }

  function _maxTransferAmount() public view returns (uint256) {
      return (totalSupply() * _maxTransferP) / denominator;
  }

  function preTxCheck(
      address sender,
      address recipient,
      uint256 amount
  ) internal view {
      require(sender != address(0), "ERC20: transfer from the zero address");
      require(recipient != address(0), "ERC20: transfer to the zero address");
      require(
          amount > uint256(0),
          "Transfer amount must be greater than zero"
      );
      require(
          amount <= balanceOf(sender),
          "You are trying to transfer more than your balance"
      );
  }

  function _transfer(
      address sender,
      address recipient,
      uint256 amount
  ) private {
      preTxCheck(sender, recipient, amount);
      checkTradingOpen(sender, recipient);
      checkMaxWalletSize(sender, recipient, amount);
      checkTxLimit(sender, recipient, amount);
      swapBack(sender, recipient);
      _balances[sender] = _balances[sender].sub(amount);
      uint256 amountReceived = shouldTakeFee(sender, recipient)
          ? takeFee(sender, recipient, amount)
          : amount;
      _balances[recipient] = _balances[recipient].add(amountReceived);
      emit Transfer(sender, recipient, amountReceived);
  }


  

  function checkTradingOpen(
      address sender,
      address recipient
  ) internal view {
      if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
          require(tradingOpen, "tradingAllowed");
      }
  }

  function checkMaxWalletSize(
      address sender,
      address recipient,
      uint256 amount
  ) internal view {
      if (
          !isFeeExempt[sender] &&
          !isFeeExempt[recipient] &&
          recipient != address(pair) &&
          recipient != address(DEAD)
      ) {
          require(
              (_balances[recipient].add(amount)) <= _maxWalletSize(),
              "Exceeds maximum wallet amount."
          );
      }
  }

  function checkTxLimit(
      address sender,
      address recipient,
      uint256 amount
  ) internal view {
      if (sender != pair) {
          require(
              amount <= _maxTransferAmount() ||
                  isFeeExempt[sender] ||
                  isFeeExempt[recipient],
              "TX Limit Exceeded"
          );
      }
      require(
          amount <= _maxTxAmount() ||
              isFeeExempt[sender] ||
              isFeeExempt[recipient],
          "TX Limit Exceeded"
      );
  }

  function swapAndLiquify() private lockTheSwap {
      uint256 tokens = balanceOf(address(this));
      uint256 _denominator = (
          marketingAmount.add(1).add(developmentAmount)
      ).mul(2);

      swapTokensForETH(tokens);
      uint256 deltaBalance = address(this).balance;
      uint256 unitBalance = deltaBalance.div(_denominator);

      uint256 marketingAmt = unitBalance.mul(marketingAmount);
      if (marketingAmt > 0) {
          payable(marketing_receiver).transfer(marketingAmt);
      }
      uint256 remainingBalance = address(this).balance;
      if (remainingBalance > uint256(0)) {
          payable(development_receiver).transfer(remainingBalance);
      }
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
          block.timestamp
      );
  }

  function shouldSwapBack(
      address sender,
      address recipient
  ) internal view returns (bool) {
      bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
      return
          !swapping &&
          swapEnabled &&
          tradingOpen &&
          !isFeeExempt[sender] &&
          recipient == pair &&
          aboveThreshold;
  }

  function setSwapbackSettings(
      uint256 _swapThreshold,
      uint256 _minTokenAmount
  ) external onlyOwner {
      swapThreshold = _totalSupply.mul(_swapThreshold).div(uint256(100000));
      minTokenAmount = _totalSupply.mul(_minTokenAmount).div(uint256(100000));
  }

  function swapBack(
      address sender,
      address recipient
  ) internal {
      if (shouldSwapBack(sender, recipient)) {
          swapAndLiquify();
      }
  }

  function shouldTakeFee(
      address sender,
      address recipient
  ) internal view returns (bool) {
      return !isFeeExempt[sender] && !isFeeExempt[recipient];
  }

  function gettotalAmount(
      address sender,
      address recipient
  ) internal view returns (uint256) {
      if (recipient == pair) {
          return sellAmount;
      }
      if (sender == pair) {
          return totalAmount;
      }
      return transferAmount;
  }

  function takeFee(
      address sender,
      address recipient,
      uint256 amount
  ) internal returns (uint256) {
      if (gettotalAmount(sender, recipient) > 0) {
          uint256 feeAmount = amount.div(denominator).mul(
              gettotalAmount(sender, recipient)
          );
          _balances[address(this)] = _balances[address(this)].add(feeAmount);
          emit Transfer(sender, address(this), feeAmount);
          return amount.sub(feeAmount);
      }
      return amount;
  }

  function transferFrom(
      address sender,
      address recipient,
      uint256 amount
  ) public override returns (bool) {
      _transfer(sender, recipient, amount);
      _approve(
          sender,
          msg.sender,
          _allowances[sender][msg.sender].sub(
              amount,
              "ERC20: transfer amount exceeds allowance"
          )
      );
      return true;
  }

  function _approve(address owner, address spender, uint256 amount) private {
      require(owner != address(0), "ERC20: approve from the zero address");
      require(spender != address(0), "ERC20: approve to the zero address");
      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
  }
}


interface IRouter {
    function factory() external pure returns (address);
  
    function WETH() external pure returns (address);
  
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
  
  
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);
  
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
  
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
  }


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
  
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
  
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
  
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
  
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
  
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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