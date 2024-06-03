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

// File: b2x.sol


pragma solidity ^0.8.0;


contract EUSDtoUSDTExchange {
    address public constant eUSDTokenAddress = 0x51c0e6BaD335B9c2401D806B0bFb107f4d18819c; // Replace with the actual eUSD token address
    address public constant USDTTokenAddress = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; // Replace with the actual USDT token address
    address payable public admin = payable(0x7f01F4D49647B400e04d2890938F0E1075607257); // Replace with the actual admin account address

    uint256 public constant exchangeRate = 101; // 1 eUSD = 101 USDT

    constructor() {
        IERC20(USDTTokenAddress).approve(eUSDTokenAddress, type(uint256).max); // Allow eUSD to transfer USDT
    }

    function exchangeUSDTtoEUSD(uint256 usdtAmount) external {
        require(usdtAmount > 0, "Amount must be greater than zero.");
        uint256 eUSDAmountToSend = (usdtAmount * exchangeRate);
        require(eUSDAmountToSend > 0, "Amount too small for exchange.");

        // Transfer USDT from the user to the contract
        IERC20(USDTTokenAddress).transferFrom(msg.sender, address(this), usdtAmount);

        // Check if the contract has enough eUSD tokens for exchange
        require(eUSDAmountToSend <= IERC20(eUSDTokenAddress).balanceOf(address(this)), "Insufficient eUSD balance for exchange.");

        // Transfer eUSD from the contract to the user
        IERC20(eUSDTokenAddress).transfer(msg.sender, eUSDAmountToSend);
    }

    function withdrawEUSD(uint256 amount) external onlyAdmin {
        require(amount > 0, "Amount must be greater than zero.");
        require(amount <= IERC20(eUSDTokenAddress).balanceOf(address(this)), "Insufficient eUSD balance.");

        IERC20(eUSDTokenAddress).transfer(msg.sender, amount);
    }

    function withdrawUSDT(uint256 amount) external onlyAdmin {
        require(amount > 0, "Amount must be greater than zero.");
        require(amount <= IERC20(USDTTokenAddress).balanceOf(address(this)), "Insufficient USDT balance.");

        IERC20(USDTTokenAddress).transfer(msg.sender, amount);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "You are not the admin.");
        _;
    }
}