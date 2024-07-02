// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/SKOLCHIPS.sol

//SPDX-License-Identifier: Unlicensed
 
pragma solidity ^0.8.4;


 
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
 
    function WETH() external pure returns (address);
 
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
 
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
 
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
 
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
 
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
 
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);
 
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
 
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
 
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
 
    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
 
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
 
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
 
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);
 
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);
 
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);
 
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
 
    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}
 
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
 
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);
 
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
 
contract SKOLCHIPSMARKET is Ownable {
    IERC20 public AGS;
    IUniswapV2Router02 public router;
 
    uint256 priceOfBuy10GChips = 10 * 10 ** 6;
    uint256 priceOfBuy25GChips = 25 * 10 ** 6;
    uint256 priceOfBuy50GChips = 50 * 10 ** 6;
    uint256 priceOfBuy100GChips = 100 * 10 ** 6;
    uint256 priceOfBuy125GChips = 125 * 10 ** 6;
    uint256 priceOfBuy200GChips = 200 * 10 ** 6;
    uint256 priceOfBuy250GChips = 250 * 10 ** 6;
 
    constructor() {
        AGS = IERC20(0xB369dACa21eE035312176Eb8Cf9d88ce97E0aA95);
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }
 
    function Buy10GChips() external returns (bool) {
        uint256 price = getPriceInAGSs(priceOfBuy10GChips);
        buy(price);
        return true;
    }
 
    function Buy25GChips() external returns (bool) {
        uint256 price = getPriceInAGSs(priceOfBuy25GChips);
        buy(price);
        return true;
    }
 
    function Buy50GChips() external returns (bool) {
        uint256 price = getPriceInAGSs(priceOfBuy50GChips);
        buy(price);
        return true;
    }
 
    function Buy100GChips() public {
        uint256 price = getPriceInAGSs(priceOfBuy100GChips);
        buy(price);
    }
 
    function Buy125GChips() external returns (bool) {
        uint256 price = getPriceInAGSs(priceOfBuy125GChips);
        buy(price);
        return true;
    }
 
    function Buy200GChips() external returns (bool) {
        uint256 price = getPriceInAGSs(priceOfBuy200GChips);
        buy(price);
        return true;
    }
 
    function Buy250GChips() external returns (bool) {
        uint256 price = getPriceInAGSs(priceOfBuy250GChips);
        buy(price);
        return true;
    }
 
    function buy(uint _amount) internal {
        uint256 amountToBurn = (_amount * 10) / 100;
        uint256 amountToContract = _amount - amountToBurn;
 
        AGS.transferFrom(
            msg.sender,
            0x000000000000000000000000000000000000dEaD,
            amountToBurn
        );
        AGS.transferFrom(
            msg.sender,
            0x9D32dF1e115fb2CA6ab6b10Fa415A514281B309C,
            amountToContract
        );
    }
 
    function getPriceInAGSs(uint256 _amount) public view returns (uint256) {
        return getPrice(_amount);
    }
 
    function changePriceOfBuy10GChips(uint256 _newPrice) external onlyOwner {
        priceOfBuy10GChips = _newPrice;
    }
 
    function changePriceOfBuy25GChips(uint256 _newPrice) external onlyOwner {
        priceOfBuy10GChips = _newPrice;
    }
 
    function changePriceOfBuy50GChips(uint256 _newPrice) external onlyOwner {
        priceOfBuy50GChips = _newPrice;
    }
 
    function changePriceOfBuy100GChips(uint256 _newPrice) external onlyOwner {
        priceOfBuy100GChips = _newPrice;
    }
 
    function changePriceOfBuy125GChips(uint256 _newPrice) external onlyOwner {
        priceOfBuy125GChips = _newPrice;
    }
 
    function changePriceOfBuy200GChips(uint256 _newPrice) external onlyOwner {
        priceOfBuy200GChips = _newPrice;
    }
 
    function changePriceOfBuy250GChips(uint256 _newPrice) external onlyOwner {
        priceOfBuy250GChips = _newPrice;
    }
 
    function getPrice(uint256 _amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        uint[] memory result = router.getAmountsOut(_amount, path);
 
        path[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        path[1] = address(AGS);
        uint[] memory finalResult = router.getAmountsOut(result[1], path);
        return finalResult[1];
    }
}