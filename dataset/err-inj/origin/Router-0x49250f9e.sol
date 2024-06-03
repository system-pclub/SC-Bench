// SPDX-License-Identifier: MIT

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.13;

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is disstributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

interface IFlashCallback {
    function flashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external;
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
  /*
   * Minimum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  /*
   * Maximum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Convert signed 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromInt (int256 x) internal pure returns (int128) {
    unchecked {
      require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (x << 64);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 64-bit integer number
   * rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64-bit integer number
   */
  function toInt (int128 x) internal pure returns (int64) {
    unchecked {
      return int64 (x >> 64);
    }
  }

  /**
   * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromUInt (uint256 x) internal pure returns (int128) {
    unchecked {
      require (x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (int256 (x << 64));
    }
  }

  /**
   * Convert signed 64.64 fixed point number into unsigned 64-bit integer
   * number rounding down.  Revert on underflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return unsigned 64-bit integer number
   */
  function toUInt (int128 x) internal pure returns (uint64) {
    unchecked {
      require (x >= 0);
      return uint64 (uint128 (x >> 64));
    }
  }

  /**
   * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
   * number rounding down.  Revert on overflow.
   *
   * @param x signed 128.128-bin fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function from128x128 (int256 x) internal pure returns (int128) {
    unchecked {
      int256 result = x >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 128.128 fixed point
   * number.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 128.128 fixed point number
   */
  function to128x128 (int128 x) internal pure returns (int256) {
    unchecked {
      return int256 (x) << 64;
    }
  }

  /**
   * Calculate x + y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function add (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) + y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x - y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sub (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) - y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding down.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function mul (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) * y >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
   * number and y is signed 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y signed 256-bit integer number
   * @return signed 256-bit integer number
   */
  function muli (int128 x, int256 y) internal pure returns (int256) {
    unchecked {
      if (x == MIN_64x64) {
        require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
          y <= 0x1000000000000000000000000000000000000000000000000);
        return -y << 63;
      } else {
        bool negativeResult = false;
        if (x < 0) {
          x = -x;
          negativeResult = true;
        }
        if (y < 0) {
          y = -y; // We rely on overflow behavior here
          negativeResult = !negativeResult;
        }
        uint256 absoluteResult = mulu (x, uint256 (y));
        if (negativeResult) {
          require (absoluteResult <=
            0x8000000000000000000000000000000000000000000000000000000000000000);
          return -int256 (absoluteResult); // We rely on overflow behavior here
        } else {
          require (absoluteResult <=
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
          return int256 (absoluteResult);
        }
      }
    }
  }

  /**
   * Calculate x * y rounding down, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y unsigned 256-bit integer number
   * @return unsigned 256-bit integer number
   */
  function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    unchecked {
      if (y == 0) return 0;

      require (x >= 0);

      uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      uint256 hi = uint256 (int256 (x)) * (y >> 128);

      require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      hi <<= 64;

      require (hi <=
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
      return hi + lo;
    }
  }

  /**
   * Calculate x / y rounding towards zero.  Revert on overflow or when y is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function div (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      int256 result = (int256 (x) << 64) / y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are signed 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divi (int256 x, int256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);

      bool negativeResult = false;
      if (x < 0) {
        x = -x; // We rely on overflow behavior here
        negativeResult = true;
      }
      if (y < 0) {
        y = -y; // We rely on overflow behavior here
        negativeResult = !negativeResult;
      }
      uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
      if (negativeResult) {
        require (absoluteResult <= 0x80000000000000000000000000000000);
        return -int128 (absoluteResult); // We rely on overflow behavior here
      } else {
        require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int128 (absoluteResult); // We rely on overflow behavior here
      }
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divu (uint256 x, uint256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      uint128 result = divuu (x, y);
      require (result <= uint128 (MAX_64x64));
      return int128 (result);
    }
  }

  /**
   * Calculate -x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function neg (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return -x;
    }
  }

  /**
   * Calculate |x|.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function abs (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return x < 0 ? -x : x;
    }
  }

  /**
   * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function inv (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != 0);
      int256 result = int256 (0x100000000000000000000000000000000) / x;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function avg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      return int128 ((int256 (x) + int256 (y)) >> 1);
    }
  }

  /**
   * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
   * Revert on overflow or in case x * y is negative.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function gavg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 m = int256 (x) * int256 (y);
      require (m >= 0);
      require (m <
          0x4000000000000000000000000000000000000000000000000000000000000000);
      return int128 (sqrtu (uint256 (m)));
    }
  }

  /**
   * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y uint256 value
   * @return signed 64.64-bit fixed point number
   */
  function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
      bool negative = x < 0 && y & 1 == 1;

      uint256 absX = uint128 (x < 0 ? -x : x);
      uint256 absResult;
      absResult = 0x100000000000000000000000000000000;

      if (absX <= 0x10000000000000000) {
        absX <<= 63;
        while (y != 0) {
          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x2 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x4 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x8 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          y >>= 4;
        }

        absResult >>= 64;
      } else {
        uint256 absXShift = 63;
        if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
        if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
        if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
        if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
        if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
        if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }

        uint256 resultShift = 0;
        while (y != 0) {
          require (absXShift < 64);

          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
            resultShift += absXShift;
            if (absResult > 0x100000000000000000000000000000000) {
              absResult >>= 1;
              resultShift += 1;
            }
          }
          absX = absX * absX >> 127;
          absXShift <<= 1;
          if (absX >= 0x100000000000000000000000000000000) {
              absX >>= 1;
              absXShift += 1;
          }

          y >>= 1;
        }

        require (resultShift < 64);
        absResult >>= 64 - resultShift;
      }
      int256 result = negative ? -int256 (absResult) : int256 (absResult);
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down.  Revert if x < 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
      require (x >= 0);
      return int128 (sqrtu (uint256 (int256 (x)) << 64));
    }
  }

  /**
   * Calculate binary logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      int256 msb = 0;
      int256 xc = x;
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

      int256 result = msb - 64 << 64;
      uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256 (b);
      }

      return int128 (result);
    }
  }

  /**
   * Calculate natural logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function ln (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      return int128 (int256 (
          uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
    }
  }

  /**
   * Calculate binary exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      uint256 result = 0x80000000000000000000000000000000;

      if (x & 0x8000000000000000 > 0)
        result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (x & 0x4000000000000000 > 0)
        result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (x & 0x2000000000000000 > 0)
        result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (x & 0x1000000000000000 > 0)
        result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (x & 0x800000000000000 > 0)
        result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (x & 0x400000000000000 > 0)
        result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (x & 0x200000000000000 > 0)
        result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (x & 0x100000000000000 > 0)
        result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (x & 0x80000000000000 > 0)
        result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (x & 0x40000000000000 > 0)
        result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (x & 0x20000000000000 > 0)
        result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (x & 0x10000000000000 > 0)
        result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (x & 0x8000000000000 > 0)
        result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (x & 0x4000000000000 > 0)
        result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (x & 0x2000000000000 > 0)
        result = result * 0x1000162E525EE054754457D5995292026 >> 128;
      if (x & 0x1000000000000 > 0)
        result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (x & 0x800000000000 > 0)
        result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (x & 0x400000000000 > 0)
        result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (x & 0x200000000000 > 0)
        result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (x & 0x100000000000 > 0)
        result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (x & 0x80000000000 > 0)
        result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (x & 0x40000000000 > 0)
        result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (x & 0x20000000000 > 0)
        result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (x & 0x10000000000 > 0)
        result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (x & 0x8000000000 > 0)
        result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (x & 0x4000000000 > 0)
        result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (x & 0x2000000000 > 0)
        result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (x & 0x1000000000 > 0)
        result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (x & 0x800000000 > 0)
        result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (x & 0x400000000 > 0)
        result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (x & 0x200000000 > 0)
        result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (x & 0x100000000 > 0)
        result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (x & 0x80000000 > 0)
        result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (x & 0x40000000 > 0)
        result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (x & 0x20000000 > 0)
        result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (x & 0x10000000 > 0)
        result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (x & 0x8000000 > 0)
        result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (x & 0x4000000 > 0)
        result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (x & 0x2000000 > 0)
        result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (x & 0x1000000 > 0)
        result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (x & 0x800000 > 0)
        result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (x & 0x400000 > 0)
        result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (x & 0x200000 > 0)
        result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (x & 0x100000 > 0)
        result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (x & 0x80000 > 0)
        result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (x & 0x40000 > 0)
        result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (x & 0x20000 > 0)
        result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (x & 0x10000 > 0)
        result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (x & 0x8000 > 0)
        result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (x & 0x4000 > 0)
        result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (x & 0x2000 > 0)
        result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (x & 0x1000 > 0)
        result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (x & 0x800 > 0)
        result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (x & 0x400 > 0)
        result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (x & 0x200 > 0)
        result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (x & 0x100 > 0)
        result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (x & 0x80 > 0)
        result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (x & 0x40 > 0)
        result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (x & 0x20 > 0)
        result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (x & 0x10 > 0)
        result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (x & 0x8 > 0)
        result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (x & 0x4 > 0)
        result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (x & 0x2 > 0)
        result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (x & 0x1 > 0)
        result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

      result >>= uint256 (int256 (63 - (x >> 64)));
      require (result <= uint256 (int256 (MAX_64x64)));

      return int128 (int256 (result));
    }
  }

  /**
   * Calculate natural exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      return exp_2 (
          int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return unsigned 64.64-bit fixed point number
   */
  function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    unchecked {
      require (y != 0);

      uint256 result;

      if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        result = (x << 64) / y;
      else {
        uint256 msb = 192;
        uint256 xc = x >> 192;
        if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
        if (xc >= 0x10000) { xc >>= 16; msb += 16; }
        if (xc >= 0x100) { xc >>= 8; msb += 8; }
        if (xc >= 0x10) { xc >>= 4; msb += 4; }
        if (xc >= 0x4) { xc >>= 2; msb += 2; }
        if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

        result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
        require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 hi = result * (y >> 128);
        uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 xh = x >> 192;
        uint256 xl = x << 64;

        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here
        lo = hi << 128;
        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here

        assert (xh == hi >> 128);

        result += xl / y;
      }

      require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return uint128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
   * number.
   *
   * @param x unsigned 256-bit integer number
   * @return unsigned 128-bit integer number
   */
  function sqrtu (uint256 x) private pure returns (uint128) {
    unchecked {
      if (x == 0) return 0;
      else {
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
        if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
        if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
        if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
        if (xx >= 0x100) { xx >>= 8; r <<= 4; }
        if (xx >= 0x10) { xx >>= 4; r <<= 2; }
        if (xx >= 0x8) { r <<= 1; }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return uint128 (r < r1 ? r : r1);
      }
    }
  }
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

interface IAssimilator {
    function oracleDecimals() external view returns (uint256);

    function underlyingToken() external view returns (address);

    function getWeth() external view returns (address);

    function tokenDecimals() external view returns (uint256);

    function getRate() external view returns (uint256);

    function intakeRaw(uint256 amount) external payable returns (int128);

    function intakeRawAndGetBalance(
        uint256 amount
    ) external payable returns (int128, int128);

    function intakeNumeraire(int128 amount) external payable returns (uint256);

    function intakeNumeraireLPRatio(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        int128
    ) external payable returns (uint256);

    function outputRaw(address dst, uint256 amount) external returns (int128);

    function outputRawAndGetBalance(
        address dst,
        uint256 amount
    ) external returns (int128, int128);

    function outputNumeraire(
        address dst,
        int128 amount,
        bool toETH
    ) external payable returns (uint256);

    function viewRawAmount(int128) external view returns (uint256);

    function viewRawAmountLPRatio(
        uint256,
        uint256,
        address,
        int128
    ) external view returns (uint256);

    function viewNumeraireAmount(uint256) external view returns (int128);

    function viewNumeraireBalanceLPRatio(
        uint256,
        uint256,
        address
    ) external view returns (int128);

    function viewNumeraireBalance(address) external view returns (int128);

    function viewNumeraireAmountAndBalance(
        address,
        uint256
    ) external view returns (int128, int128);

    function transferFee(int128, address) external payable;
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

interface IOracle {
    function acceptOwnership() external;

    function accessController() external view returns (address);

    function aggregator() external view returns (address);

    function confirmAggregator(address _aggregator) external;

    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function getAnswer(uint256 _roundId) external view returns (int256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function getTimestamp(uint256 _roundId) external view returns (uint256);

    function latestAnswer() external view returns (int256);

    function latestRound() external view returns (uint256);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestTimestamp() external view returns (uint256);

    function owner() external view returns (address);

    function phaseAggregators(uint16) external view returns (address);

    function phaseId() external view returns (uint16);

    function proposeAggregator(address _aggregator) external;

    function proposedAggregator() external view returns (address);

    function proposedGetRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function proposedLatestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function setController(address _accessController) external;

    function transferOwnership(address _to) external;

    function version() external view returns (uint256);
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

interface IERC20Detailed is IERC20 {
    function name() external returns (string memory);

    function symbol() external returns (string memory);

    function decimals() external returns (uint8);

    function mint(address account, uint256 amount) external;
}

contract AssimilatorV2 is IAssimilator, ReentrancyGuard {
    using ABDKMath64x64 for int128;
    using ABDKMath64x64 for uint256;

    using SafeMath for uint256;
    using SafeERC20 for IERC20Detailed;

    IERC20Detailed public immutable pairToken;

    IOracle public immutable oracle;
    IERC20Detailed public immutable token;
    uint256 public immutable oracleDecimals;
    uint256 public immutable tokenDecimals;
    uint256 public immutable pairTokenDecimals;

    address public immutable wETH;

    // solhint-disable-next-line
    constructor(
        address _wETH,
        address _pairToken,
        IOracle _oracle,
        address _token,
        uint256 _tokenDecimals,
        uint256 _oracleDecimals
    ) {
        wETH = _wETH;
        oracle = _oracle;
        token = IERC20Detailed(_token);
        oracleDecimals = _oracleDecimals;
        tokenDecimals = _tokenDecimals;
        pairToken = IERC20Detailed(_pairToken);
        pairTokenDecimals = pairToken.decimals();
    }

    function underlyingToken() external view override returns (address) {
        return address(token);
    }

    function getWeth() external view override returns (address) {
        return wETH;
    }

    function getRate() public view override returns (uint256) {
        (, int256 price, , , ) = oracle.latestRoundData();
        require(price >= 0, "invalid price oracle");
        return uint256(price);
    }

    // takes raw eurs amount, transfers it in, calculates corresponding numeraire amount and returns it
    function intakeRawAndGetBalance(
        uint256 _amount
    ) external payable override returns (int128 amount_, int128 balance_) {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 diff = _amount - (balanceAfter - balanceBefore);
        if (diff > 0) {
            intakeMoreFromFoT(_amount, diff);
        }

        uint256 _balance = token.balanceOf(address(this));

        uint256 _rate = getRate();

        balance_ = ((_balance * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );

        amount_ = ((_amount * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );
    }

    // takes raw eurs amount, transfers it in, calculates corresponding numeraire amount and returns it
    function intakeRaw(
        uint256 _amount
    ) external payable override returns (int128 amount_) {
        uint256 balanceBefore = token.balanceOf(address(this));

        token.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 balanceAfter = token.balanceOf(address(this));

        uint256 diff = _amount - (balanceAfter - balanceBefore);
        if (diff > 0) {
            intakeMoreFromFoT(_amount, diff);
        }

        uint256 _rate = getRate();

        amount_ = ((_amount * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );
    }

    // takes a numeraire amount, calculates the raw amount of eurs, transfers it in and returns the corresponding raw amount
    function intakeNumeraire(
        int128 _amount
    ) external payable override returns (uint256 amount_) {
        uint256 _rate = getRate();

        amount_ =
            (_amount.mulu(10 ** tokenDecimals) * 10 ** oracleDecimals) /
            _rate;
        uint256 balanceBefore = token.balanceOf(address(this));

        token.safeTransferFrom(msg.sender, address(this), amount_);
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 diff = amount_ - (balanceAfter - balanceBefore);
        if (diff > 0) intakeMoreFromFoT(amount_, diff);
    }

    // takes a numeraire amount, calculates the raw amount of eurs, transfers it in and returns the corresponding raw amount
    function intakeNumeraireLPRatio(
        uint256 _baseWeight,
        uint256 _minBaseAmount,
        uint256 _maxBaseAmount,
        uint256 _pairTokenWeight,
        uint256 _minpairTokenAmount,
        uint256 _maxpairTokenAmount,
        address _addr,
        int128 _amount
    ) external payable override returns (uint256 amount_) {
        uint256 _tokenBal = token.balanceOf(_addr);

        if (_tokenBal <= 0) return 0;

        _tokenBal = _tokenBal.mul(10 ** (18 + pairTokenDecimals)).div(
            _baseWeight
        );

        uint256 _pairTokenBal = pairToken
            .balanceOf(_addr)
            .mul(10 ** (18 + tokenDecimals))
            .div(_pairTokenWeight);

        // Rate is in pair token decimals
        uint256 _rate = _pairTokenBal.mul(1e6).div(_tokenBal);

        amount_ = (_amount.mulu(10 ** tokenDecimals) * 1e6) / _rate;
        amount_ = amount_.add(1);
        if (address(token) == address(pairToken)) {
            require(
                amount_ >= _minpairTokenAmount &&
                    amount_ <= _maxpairTokenAmount,
                "Assimilator/LP Ratio imbalanced!"
            );
        } else {
            require(
                amount_ >= _minBaseAmount && amount_ <= _maxBaseAmount,
                "Assimilator/LP Ratio imbalanced!"
            );
        }
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount_);
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 diff = amount_ - (balanceAfter - balanceBefore);
        if (diff > 0) intakeMoreFromFoT(amount_, diff);
    }

    function intakeMoreFromFoT(uint256 amount_, uint256 diff) internal {
        // handle FoT token
        uint256 feePercentage = diff.mul(1e5).div(amount_).add(1);
        uint256 additionalIntakeAmt = (diff * 1e5) / (1e5 - feePercentage);
        token.safeTransferFrom(msg.sender, address(this), additionalIntakeAmt);
        // amount_ = amount_.add(additionalIntakeAmt);
        // uint256 balance2ndAfter = token.balanceOf(address(this));
        // now refund it took more than needed
        // if (balance2ndAfter > amount_) {
        //     token.safeTransferFrom(
        //         address(this),
        //         msg.sender,
        //         balance2ndAfter.sub(amount_)
        //     );
        // }
    }

    // takes a raw amount of eurs and transfers it out, returns numeraire value of the raw amount
    function outputRawAndGetBalance(
        address _dst,
        uint256 _amount
    ) external override returns (int128 amount_, int128 balance_) {
        uint256 _rate = getRate();

        token.safeTransfer(_dst, _amount);

        uint256 _balance = token.balanceOf(address(this));

        amount_ = ((_amount * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );

        balance_ = ((_balance * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );
    }

    // takes a raw amount of eurs and transfers it out, returns numeraire value of the raw amount
    function outputRaw(
        address _dst,
        uint256 _amount
    ) external override returns (int128 amount_) {
        uint256 _rate = getRate();

        token.safeTransfer(_dst, _amount);

        amount_ = ((_amount * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );
    }

    // takes a numeraire value of eurs, figures out the raw amount, transfers raw amount out, and returns raw amount
    function outputNumeraire(
        address _dst,
        int128 _amount,
        bool _toETH
    ) external payable override returns (uint256 amount_) {
        uint256 _rate = getRate();

        amount_ =
            (_amount.mulu(10 ** tokenDecimals) * 10 ** oracleDecimals) /
            _rate;
        if (_toETH) {
            IWETH(wETH).withdraw(amount_);
            (bool success, ) = payable(_dst).call{value: amount_}("");
            require(success, "Assimilator/Transfer ETH Failed");
        } else {
            token.safeTransfer(_dst, amount_);
        }
    }

    // takes a numeraire amount and returns the raw amount
    function viewRawAmount(
        int128 _amount
    ) external view override returns (uint256 amount_) {
        uint256 _rate = getRate();

        amount_ =
            (_amount.mulu(10 ** tokenDecimals) * 10 ** oracleDecimals) /
            _rate;
    }

    function viewRawAmountLPRatio(
        uint256 _baseWeight,
        uint256 _pairTokenWeight,
        address _addr,
        int128 _amount
    ) external view override returns (uint256 amount_) {
        uint256 _tokenBal = token.balanceOf(_addr);

        if (_tokenBal <= 0) return 0;

        // 1e2
        _tokenBal = _tokenBal.mul(1e18).div(_baseWeight);

        // 1e6
        uint256 _pairTokenBal = pairToken.balanceOf(_addr).mul(1e18).div(
            _pairTokenWeight
        );

        // Rate is in 1e6
        uint256 _rate = _pairTokenBal.mul(10 ** tokenDecimals).div(_tokenBal);

        // amount_ = (_amount.mulu(10 ** tokenDecimals) * 1e6) / _rate;

        amount_ =
            (_amount.mulu(10 ** tokenDecimals) * 10 ** pairTokenDecimals) /
            _rate;
    }

    // takes a raw amount and returns the numeraire amount
    function viewNumeraireAmount(
        uint256 _amount
    ) external view override returns (int128 amount_) {
        uint256 _rate = getRate();

        amount_ = ((_amount * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );
    }

    // views the numeraire value of the current balance of the reserve, in this case eurs
    function viewNumeraireBalance(
        address _addr
    ) external view override returns (int128 balance_) {
        uint256 _rate = getRate();

        uint256 _balance = token.balanceOf(_addr);

        if (_balance <= 0) return ABDKMath64x64.fromUInt(0);

        balance_ = ((_balance * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );
    }

    // views the numeraire value of the current balance of the reserve, in this case eurs
    function viewNumeraireAmountAndBalance(
        address _addr,
        uint256 _amount
    ) external view override returns (int128 amount_, int128 balance_) {
        uint256 _rate = getRate();

        amount_ = ((_amount * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );

        uint256 _balance = token.balanceOf(_addr);

        balance_ = ((_balance * _rate) / 10 ** oracleDecimals).divu(
            10 ** tokenDecimals
        );
    }

    // views the numeraire value of the current balance of the reserve, in this case eurs
    // instead of calculating with chainlink's "rate" it'll be determined by the existing
    // token ratio. This is in here to prevent LPs from losing out on future oracle price updates
    function viewNumeraireBalanceLPRatio(
        uint256 _baseWeight,
        uint256 _pairTokenWeight,
        address _addr
    ) external view override returns (int128 balance_) {
        uint256 _tokenBal = token.balanceOf(_addr);

        if (_tokenBal <= 0) return ABDKMath64x64.fromUInt(0);

        uint256 _pairTokenBal = pairToken.balanceOf(_addr).mul(1e18).div(
            _pairTokenWeight
        );

        // Rate is in 1e6
        uint256 _rate = _pairTokenBal.mul(1e18).div(
            _tokenBal.mul(1e18).div(_baseWeight)
        );

        // balance_ = ((_tokenBal * _rate) / 1e6).divu(1e18);

        balance_ = ((_tokenBal * _rate) / 10 ** pairTokenDecimals).divu(1e18);
    }

    function transferFee(
        int128 _amount,
        address _treasury
    ) external payable override {
        uint256 _rate = getRate();
        if (_amount < 0) _amount = -(_amount);
        uint256 amount = (_amount.mulu(10 ** tokenDecimals) *
            10 ** oracleDecimals) / _rate;
        token.safeTransfer(_treasury, amount);
    }
}

interface IAssimilatorFactory {
    function getAssimilator(
        address _token,
        address _quote
    ) external view returns (AssimilatorV2);

    function newAssimilator(
        address _quote,
        IOracle _oracle,
        address _token,
        uint256 _tokenDecimals
    ) external returns (AssimilatorV2);
}

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (0 - denominator) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}

/// @title Prevents delegatecall to a contract
/// @notice Base contract that provides a modifier for preventing delegatecall to methods in a child contract
abstract contract NoDelegateCall {
    /// @dev The original address of this contract
    address private immutable original;

    constructor() {
        // Immutables are computed in the init code of the contract, and then inlined into the deployed bytecode.
        // In other words, this variable won't change when it's checked at runtime.
        original = address(this);
    }

    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function checkNotDelegateCall() private view {
        require(address(this) == original);
    }

    /// @notice Prevents delegatecall into the modified method
    modifier noDelegateCall() {
        checkNotDelegateCall();
        _;
    }
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

interface ICurveFactory {
    function getProtocolFee() external view returns (int128);

    function getProtocolTreasury() external view returns (address);

    function assimilatorFactory() external view returns (IAssimilatorFactory);

    function wETH() external view returns (address);

    function isDFXCurve(address) external view returns (bool);
}

struct OriginSwapData {
    address _origin;
    address _target;
    uint256 _originAmount;
    address _recipient;
    address _curveFactory;
}

struct TargetSwapData {
    address _origin;
    address _target;
    uint256 _targetAmount;
    address _recipient;
    address _curveFactory;
}

struct SwapInfo {
    int128 totalAmount;
    int128 totalFee;
    int128 amountToUser;
    int128 amountToTreasury;
    int128 protocolFeePercentage;
    address treasury;
    ICurveFactory curveFactory;
}

struct CurveInfo {
    string _name;
    string _symbol;
    address _baseCurrency;
    address _quoteCurrency;
    uint256 _baseWeight;
    uint256 _quoteWeight;
    IOracle _baseOracle;
    IOracle _quoteOracle;
    uint256 _alpha;
    uint256 _beta;
    uint256 _feeAtHalt;
    uint256 _epsilon;
    uint256 _lambda;
}

struct DepositData {
    uint256 deposits;
    uint256 minQuote;
    uint256 minBase;
    uint256 maxQuote;
    uint256 maxBase;
}

struct IntakeNumLpRatioInfo {
    uint256 baseWeight;
    uint256 minBase;
    uint256 maxBase;
    uint256 quoteWeight;
    uint256 minQuote;
    uint256 maxQuote;
    int128 amount;
}

struct CurveIDPair {
    bytes32 curveId;
    bytes32 curveIdReversed;
}

library Assimilators {
    using ABDKMath64x64 for int128;
    using Address for address;

    IAssimilator public constant iAsmltr = IAssimilator(address(0));

    function delegate(
        address _callee,
        bytes memory _data
    ) internal returns (bytes memory) {
        require(_callee.isContract(), "Assimilators/callee-is-not-a-contract");
        // solhint-disable-next-line
        (bool _success, bytes memory returnData_) = _callee.delegatecall(_data);

        // solhint-disable-next-line
        assembly {
            if eq(_success, 0) {
                revert(add(returnData_, 0x20), returndatasize())
            }
        }
        return returnData_;
    }

    function getRate(address _assim) internal view returns (uint256 amount_) {
        amount_ = IAssimilator(_assim).getRate();
    }

    function viewRawAmount(
        address _assim,
        int128 _amt
    ) internal view returns (uint256 amount_) {
        amount_ = IAssimilator(_assim).viewRawAmount(_amt);
    }

    function viewRawAmountLPRatio(
        address _assim,
        uint256 _baseWeight,
        uint256 _quoteWeight,
        int128 _amount
    ) internal view returns (uint256 amount_) {
        amount_ = IAssimilator(_assim).viewRawAmountLPRatio(
            _baseWeight,
            _quoteWeight,
            address(this),
            _amount
        );
    }

    function viewNumeraireAmount(
        address _assim,
        uint256 _amt
    ) internal view returns (int128 amt_) {
        amt_ = IAssimilator(_assim).viewNumeraireAmount(_amt);
    }

    function viewNumeraireAmountAndBalance(
        address _assim,
        uint256 _amt
    ) internal view returns (int128 amt_, int128 bal_) {
        (amt_, bal_) = IAssimilator(_assim).viewNumeraireAmountAndBalance(
            address(this),
            _amt
        );
    }

    function viewNumeraireBalance(
        address _assim
    ) internal view returns (int128 bal_) {
        bal_ = IAssimilator(_assim).viewNumeraireBalance(address(this));
    }

    function viewNumeraireBalanceLPRatio(
        uint256 _baseWeight,
        uint256 _quoteWeight,
        address _assim
    ) internal view returns (int128 bal_) {
        bal_ = IAssimilator(_assim).viewNumeraireBalanceLPRatio(
            _baseWeight,
            _quoteWeight,
            address(this)
        );
    }

    function intakeRaw(
        address _assim,
        uint256 _amt
    ) internal returns (int128 amt_) {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.intakeRaw.selector,
            _amt
        );

        amt_ = abi.decode(delegate(_assim, data), (int128));
    }

    function intakeRawAndGetBalance(
        address _assim,
        uint256 _amt
    ) internal returns (int128 amt_, int128 bal_) {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.intakeRawAndGetBalance.selector,
            _amt
        );

        (amt_, bal_) = abi.decode(delegate(_assim, data), (int128, int128));
    }

    function intakeNumeraire(
        address _assim,
        int128 _amt
    ) internal returns (uint256 amt_) {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.intakeNumeraire.selector,
            _amt
        );
        amt_ = abi.decode(delegate(_assim, data), (uint256));
    }

    function intakeNumeraireLPRatio(
        address _assim,
        IntakeNumLpRatioInfo memory info
    ) internal returns (uint256 amt_) {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.intakeNumeraireLPRatio.selector,
            info.baseWeight,
            info.minBase,
            info.maxBase,
            info.quoteWeight,
            info.minQuote,
            info.maxQuote,
            address(this),
            // _amount
            info.amount
        );

        amt_ = abi.decode(delegate(_assim, data), (uint256));
    }

    function outputRaw(
        address _assim,
        address _dst,
        uint256 _amt
    ) internal returns (int128 amt_) {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.outputRaw.selector,
            _dst,
            _amt
        );

        amt_ = abi.decode(delegate(_assim, data), (int128));

        amt_ = amt_.neg();
    }

    function outputRawAndGetBalance(
        address _assim,
        address _dst,
        uint256 _amt
    ) internal returns (int128 amt_, int128 bal_) {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.outputRawAndGetBalance.selector,
            _dst,
            _amt
        );

        (amt_, bal_) = abi.decode(delegate(_assim, data), (int128, int128));

        amt_ = amt_.neg();
    }

    function outputNumeraire(
        address _assim,
        address _dst,
        int128 _amt,
        bool _toETH
    ) internal returns (uint256 amt_) {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.outputNumeraire.selector,
            _dst,
            _amt.abs(),
            _toETH
        );

        amt_ = abi.decode(delegate(_assim, data), (uint256));
    }

    function transferFee(
        address _assim,
        int128 _amt,
        address _treasury
    ) internal {
        bytes memory data = abi.encodeWithSelector(
            iAsmltr.transferFee.selector,
            _amt,
            _treasury
        );
        delegate(_assim, data);
    }
}

contract Storage {
    struct Curve {
        // Curve parameters
        int128 alpha;
        int128 beta;
        int128 delta;
        int128 epsilon;
        int128 lambda;
        int128[] weights;
        // Assets and their assimilators
        Assimilator[] assets;
        mapping(address => Assimilator) assimilators;
        // Oracles to determine the price
        // Note that 0'th index should always be USDC 1e18
        // Oracle's pricing should be denominated in Currency/USDC
        mapping(address => IOracle) oracles;
        // ERC20 Interface
        uint256 totalSupply;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }

    struct Assimilator {
        address addr;
        uint8 ix;
    }

    // Curve parameters
    Curve public curve;

    // Ownable
    address public owner;

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    address[] public derivatives;
    address[] public numeraires;
    address[] public reserves;

    // Curve operational state
    bool public frozen = false;
    bool public emergency = false;
    bool internal notEntered = true;
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

library UnsafeMath64x64 {

  /**
   * Calculate x * y rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */

  function us_mul (int128 x, int128 y) internal pure returns (int128) {
    int256 result = int256(x) * y >> 64;
    return int128 (result);
  }

  /**
   * Calculate x / y rounding towards zero.  Revert on overflow or when y is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */

  function us_div (int128 x, int128 y) internal pure returns (int128) {
    int256 result = (int256 (x) << 64) / y;
    return int128 (result);
  }

}

library CurveMath {
    int128 private constant ONE = 0x10000000000000000;
    int128 private constant MAX = 0x4000000000000000; // .25 in layman's terms
    int128 private constant MAX_DIFF = -0x10C6F7A0B5EE;
    int128 private constant ONE_WEI = 0x12;

    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;
    using ABDKMath64x64 for uint256;

    // This is used to prevent stack too deep errors
    function calculateFee(
        int128 _gLiq,
        int128[] memory _bals,
        Storage.Curve storage curve,
        int128[] memory _weights
    ) internal view returns (int128 psi_) {
        int128 _beta = curve.beta;
        int128 _delta = curve.delta;

        psi_ = calculateFee(_gLiq, _bals, _beta, _delta, _weights);
    }

    function calculateFee(
        int128 _gLiq,
        int128[] memory _bals,
        int128 _beta,
        int128 _delta,
        int128[] memory _weights
    ) internal pure returns (int128 psi_) {
        uint256 _length = _bals.length;

        for (uint256 i = 0; i < _length; i++) {
            int128 _ideal = _gLiq.mul(_weights[i]);
            psi_ += calculateMicroFee(_bals[i], _ideal, _beta, _delta);
        }
    }

    function calculateMicroFee(
        int128 _bal,
        int128 _ideal,
        int128 _beta,
        int128 _delta
    ) private pure returns (int128 fee_) {
        if (_bal < _ideal) {
            int128 _threshold = _ideal.mul(ONE - _beta);

            if (_bal < _threshold) {
                int128 _feeMargin = _threshold - _bal;

                fee_ = _feeMargin.mul(_delta);
                fee_ = fee_.div(_ideal);

                if (fee_ > MAX) fee_ = MAX;

                fee_ = fee_.mul(_feeMargin);
            } else fee_ = 0;
        } else {
            int128 _threshold = _ideal.mul(ONE + _beta);

            if (_bal > _threshold) {
                int128 _feeMargin = _bal - _threshold;

                fee_ = _feeMargin.mul(_delta);
                fee_ = fee_.div(_ideal);

                if (fee_ > MAX) fee_ = MAX;

                fee_ = fee_.mul(_feeMargin);
            } else fee_ = 0;
        }
    }

    function calculateTrade(
        Storage.Curve storage curve,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals,
        int128 _inputAmt,
        uint256 _outputIndex
    ) internal view returns (int128 outputAmt_) {
        outputAmt_ = -_inputAmt;

        int128 _lambda = curve.lambda;
        int128[] memory _weights = curve.weights;

        int128 _omega = calculateFee(_oGLiq, _oBals, curve, _weights);
        int128 _psi;

        for (uint256 i = 0; i < 32; i++) {
            _psi = calculateFee(_nGLiq, _nBals, curve, _weights);

            int128 prevAmount;
            {
                prevAmount = outputAmt_;
                outputAmt_ = _omega < _psi
                    ? -(_inputAmt + _omega - _psi)
                    : -(_inputAmt + _lambda.mul(_omega - _psi));
            }

            if (outputAmt_ / 1e13 == prevAmount / 1e13) {
                _nGLiq = _oGLiq + _inputAmt + outputAmt_;

                _nBals[_outputIndex] = _oBals[_outputIndex] + outputAmt_;

                enforceHalts(curve, _oGLiq, _nGLiq, _oBals, _nBals, _weights);

                enforceSwapInvariant(_oGLiq, _omega, _nGLiq, _psi);
                return outputAmt_;
            } else {
                _nGLiq = _oGLiq + _inputAmt + outputAmt_;

                _nBals[_outputIndex] = _oBals[_outputIndex].add(outputAmt_);
            }
        }

        revert("Curve/swap-convergence-failed");
    }

    function calculateLiquidityMembrane(
        Storage.Curve storage curve,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals
    ) internal view returns (int128 curves_) {
        enforceHalts(curve, _oGLiq, _nGLiq, _oBals, _nBals, curve.weights);

        int128 _omega;
        int128 _psi;

        {
            int128 _beta = curve.beta;
            int128 _delta = curve.delta;
            int128[] memory _weights = curve.weights;

            _omega = calculateFee(_oGLiq, _oBals, _beta, _delta, _weights);
            _psi = calculateFee(_nGLiq, _nBals, _beta, _delta, _weights);
        }

        int128 _feeDiff = _psi.sub(_omega);
        int128 _liqDiff = _nGLiq.sub(_oGLiq);
        int128 _oUtil = _oGLiq.sub(_omega);
        int128 _totalShells = curve.totalSupply.divu(1e18);
        int128 _curveMultiplier;

        if (_totalShells == 0) {
            curves_ = _nGLiq.sub(_psi);
        } else if (_feeDiff >= 0) {
            _curveMultiplier = _liqDiff.sub(_feeDiff).div(_oUtil);
        } else {
            _curveMultiplier = _liqDiff.sub(curve.lambda.mul(_feeDiff));

            _curveMultiplier = _curveMultiplier.div(_oUtil);
        }

        if (_totalShells != 0) {
            curves_ = _totalShells.mul(_curveMultiplier);
        }
    }

    function enforceSwapInvariant(
        int128 _oGLiq,
        int128 _omega,
        int128 _nGLiq,
        int128 _psi
    ) private pure {
        int128 _nextUtil = _nGLiq - _psi;

        int128 _prevUtil = _oGLiq - _omega;

        int128 _diff = _nextUtil - _prevUtil;

        require(
            0 < _diff || _diff >= MAX_DIFF,
            "Curve/swap-invariant-violation"
        );
    }

    function enforceHalts(
        Storage.Curve storage curve,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals,
        int128[] memory _weights
    ) private view {
        uint256 _length = _nBals.length;
        int128 _alpha = curve.alpha;

        for (uint256 i = 0; i < _length; i++) {
            int128 _nIdeal = _nGLiq.mul(_weights[i]);

            if (_nBals[i] > _nIdeal) {
                int128 _upperAlpha = ONE + _alpha;

                int128 _nHalt = _nIdeal.mul(_upperAlpha);

                if (_nBals[i] > _nHalt) {
                    int128 _oHalt = _oGLiq.mul(_weights[i]).mul(_upperAlpha);

                    if (_oBals[i] < _oHalt) revert("Curve/upper-halt");
                    if (_nBals[i] - _nHalt > _oBals[i] - _oHalt)
                        revert("Curve/upper-halt");
                }
            } else {
                int128 _lowerAlpha = ONE - _alpha;

                int128 _nHalt = _nIdeal.mul(_lowerAlpha);

                if (_nBals[i] < _nHalt) {
                    int128 _oHalt = _oGLiq.mul(_weights[i]);
                    _oHalt = _oHalt.mul(_lowerAlpha);

                    if (_oBals[i] > _oHalt) revert("Curve/lower-halt");
                    if (_nHalt - _nBals[i] > _oHalt - _oBals[i])
                        revert("Curve/lower-halt");
                }
            }
        }
    }
}

library Orchestrator {
    using SafeERC20 for IERC20;
    using ABDKMath64x64 for int128;
    using ABDKMath64x64 for uint256;

    int128 private constant ONE_WEI = 0x12;

    event ParametersSet(
        uint256 alpha,
        uint256 beta,
        uint256 delta,
        uint256 epsilon,
        uint256 lambda
    );

    event AssetIncluded(
        address indexed numeraire,
        address indexed reserve,
        uint256 weight
    );

    event AssimilatorIncluded(
        address indexed derivative,
        address indexed numeraire,
        address indexed reserve,
        address assimilator
    );

    function setParams(
        Storage.Curve storage curve,
        uint256 _alpha,
        uint256 _beta,
        uint256 _feeAtHalt,
        uint256 _epsilon,
        uint256 _lambda
    ) external {
        require(0 < _alpha && _alpha < 1e18, "Curve/parameter-invalid-alpha");

        require(_beta < _alpha, "Curve/parameter-invalid-beta");

        require(_feeAtHalt <= 5e17, "Curve/parameter-invalid-max");

        require(_epsilon <= 1e16, "Curve/parameter-invalid-epsilon");

        require(_lambda <= 1e18, "Curve/parameter-invalid-lambda");

        int128 _omega = getFee(curve);

        curve.alpha = (_alpha + 1).divu(1e18);

        curve.beta = (_beta + 1).divu(1e18);

        curve.delta =
            (_feeAtHalt).divu(1e18).div(
                uint256(2).fromUInt().mul(curve.alpha.sub(curve.beta))
            ) +
            ONE_WEI;

        curve.epsilon = (_epsilon + 1).divu(1e18);

        curve.lambda = (_lambda + 1).divu(1e18);

        int128 _psi = getFee(curve);

        require(_omega >= _psi, "Curve/parameters-increase-fee");

        emit ParametersSet(
            _alpha,
            _beta,
            curve.delta.mulu(1e18),
            _epsilon,
            _lambda
        );
    }

    function setAssimilator(
        Storage.Curve storage curve,
        address _baseCurrency,
        address _baseAssim,
        address _quoteCurrency,
        address _quoteAssim
    ) external {
        require(
            _baseCurrency != address(0),
            "Curve/numeraire-cannot-be-zero-address"
        );
        require(
            _baseAssim != address(0),
            "Curve/numeraire-assimilator-cannot-be-zero-address"
        );
        require(
            _quoteCurrency != address(0),
            "Curve/reserve-cannot-be-zero-address"
        );
        require(
            _quoteAssim != address(0),
            "Curve/reserve-assimilator-cannot-be-zero-address"
        );

        Storage.Assimilator storage _baseAssimilator = curve.assimilators[
            _baseCurrency
        ];
        _baseAssimilator.addr = _baseAssim;

        Storage.Assimilator storage _quoteAssimilator = curve.assimilators[
            _quoteCurrency
        ];
        _quoteAssimilator.addr = _quoteAssim;

        curve.assets[0] = _baseAssimilator;
        curve.assets[1] = _quoteAssimilator;
    }

    function getFee(
        Storage.Curve storage curve
    ) private view returns (int128 fee_) {
        int128 _gLiq;

        // Always pairs
        int128[] memory _bals = new int128[](2);

        for (uint256 i = 0; i < _bals.length; i++) {
            int128 _bal = Assimilators.viewNumeraireBalance(
                curve.assets[i].addr
            );

            _bals[i] = _bal;

            _gLiq += _bal;
        }

        fee_ = CurveMath.calculateFee(
            _gLiq,
            _bals,
            curve.beta,
            curve.delta,
            curve.weights
        );
    }

    function initialize(
        Storage.Curve storage curve,
        address[] storage numeraires,
        address[] storage reserves,
        address[] storage derivatives,
        address[] calldata _assets,
        uint256[] calldata _assetWeights
    ) external {
        require(
            _assetWeights.length == 2,
            "Curve/assetWeights-must-be-length-two"
        );
        require(
            _assets.length % 5 == 0,
            "Curve/assets-must-be-divisible-by-five"
        );

        for (uint256 i = 0; i < _assetWeights.length; i++) {
            uint256 ix = i * 5;

            numeraires.push(_assets[ix]);
            derivatives.push(_assets[ix]);

            reserves.push(_assets[2 + ix]);
            if (_assets[ix] != _assets[2 + ix])
                derivatives.push(_assets[2 + ix]);

            includeAsset(
                curve,
                _assets[ix], // numeraire
                _assets[1 + ix], // numeraire assimilator
                _assets[2 + ix], // reserve
                _assets[3 + ix], // reserve assimilator
                _assets[4 + ix], // reserve approve to
                _assetWeights[i]
            );
        }
    }

    function includeAsset(
        Storage.Curve storage curve,
        address _numeraire,
        address _numeraireAssim,
        address _reserve,
        address _reserveAssim,
        address _reserveApproveTo,
        uint256 _weight
    ) private {
        require(
            _numeraire != address(0),
            "Curve/numeraire-cannot-be-zero-address"
        );

        require(
            _numeraireAssim != address(0),
            "Curve/numeraire-assimilator-cannot-be-zero-address"
        );

        require(_reserve != address(0), "Curve/reserve-cannot-be-zero-address");

        require(
            _reserveAssim != address(0),
            "Curve/reserve-assimilator-cannot-be-zero-address"
        );

        require(_weight < 1e18, "Curve/weight-must-be-less-than-one");

        if (_numeraire != _reserve)
            IERC20(_numeraire).safeApprove(_reserveApproveTo, type(uint).max);

        Storage.Assimilator storage _numeraireAssimilator = curve.assimilators[
            _numeraire
        ];

        _numeraireAssimilator.addr = _numeraireAssim;

        _numeraireAssimilator.ix = uint8(curve.assets.length);

        Storage.Assimilator storage _reserveAssimilator = curve.assimilators[
            _reserve
        ];

        _reserveAssimilator.addr = _reserveAssim;

        _reserveAssimilator.ix = uint8(curve.assets.length);

        int128 __weight = _weight.divu(1e18).add(uint256(1).divu(1e18));

        curve.weights.push(__weight);

        curve.assets.push(_numeraireAssimilator);

        emit AssetIncluded(_numeraire, _reserve, _weight);

        emit AssimilatorIncluded(
            _numeraire,
            _numeraire,
            _reserve,
            _numeraireAssim
        );

        if (_numeraireAssim != _reserveAssim) {
            emit AssimilatorIncluded(
                _reserve,
                _numeraire,
                _reserve,
                _reserveAssim
            );
        }
    }

    function viewCurve(
        Storage.Curve storage curve
    )
        external
        view
        returns (
            uint256 alpha_,
            uint256 beta_,
            uint256 delta_,
            uint256 epsilon_,
            uint256 lambda_
        )
    {
        alpha_ = curve.alpha.mulu(1e18);

        beta_ = curve.beta.mulu(1e18);

        delta_ = curve.delta.mulu(1e18);

        epsilon_ = curve.epsilon.mulu(1e18);

        lambda_ = curve.lambda.mulu(1e18);
    }
}

// import "forge-std/Test.sol";

library ProportionalLiquidity {
    using ABDKMath64x64 for uint256;
    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    int128 public constant ONE = 0x10000000000000000;
    int128 public constant ONE_WEI = 0x12;

    function proportionalDeposit(
        Storage.Curve storage curve,
        DepositData memory depositData
    ) external returns (uint256 curves_, uint256[] memory) {
        int128 __deposit = depositData.deposits.divu(1e18);

        uint256 _length = curve.assets.length;

        uint256[] memory deposits_ = new uint256[](_length);

        (
            int128 _oGLiq,
            int128[] memory _oBals
        ) = getGrossLiquidityAndBalancesForDeposit(curve);

        // No liquidity, oracle sets the ratio
        if (_oGLiq == 0) {
            for (uint256 i = 0; i < _length; i++) {
                // Variable here to avoid stack-too-deep errors
                int128 _d = __deposit.mul(curve.weights[i]);
                deposits_[i] = Assimilators.intakeNumeraire(
                    curve.assets[i].addr,
                    _d.add(ONE_WEI)
                );
            }
        } else {
            // We already have an existing pool ratio
            // which must be respected
            int128 _multiplier = __deposit.div(_oGLiq);

            uint256 _baseWeight = curve.weights[0].mulu(1e18);
            uint256 _quoteWeight = curve.weights[1].mulu(1e18);

            for (uint256 i = 0; i < _length; i++) {
                IntakeNumLpRatioInfo memory info;
                info.baseWeight = _baseWeight;
                info.minBase = depositData.minBase;
                info.maxBase = depositData.maxBase;
                info.quoteWeight = _quoteWeight;
                info.minQuote = depositData.minQuote;
                info.maxQuote = depositData.maxQuote;
                info.amount = _oBals[i].mul(_multiplier).add(ONE_WEI);
                deposits_[i] = Assimilators.intakeNumeraireLPRatio(
                    curve.assets[i].addr,
                    info
                );
            }
        }

        int128 _totalShells = curve.totalSupply.divu(1e18);

        int128 _newShells = __deposit;

        if (_totalShells > 0) {
            _newShells = __deposit.mul(_totalShells);
            _newShells = _newShells.div(_oGLiq);
        }

        require(
            _newShells > 0,
            "Proportional Liquidity/can't mint negative amount"
        );
        curves_ = _newShells.mulu(1e18);
        curves_ = curves_.div(1e17).mul(1e17);
        mint(curve, msg.sender, curves_);

        return (curves_, deposits_);
    }

    function viewProportionalDeposit(
        Storage.Curve storage curve,
        uint256 _deposit
    ) external view returns (uint256 curves_, uint256[] memory) {
        int128 __deposit = _deposit.divu(1e18);

        uint256 _length = curve.assets.length;

        (
            int128 _oGLiq,
            int128[] memory _oBals
        ) = getGrossLiquidityAndBalancesForDeposit(curve);

        uint256[] memory deposits_ = new uint256[](_length);

        // No liquidity
        if (_oGLiq == 0) {
            for (uint256 i = 0; i < _length; i++) {
                deposits_[i] = Assimilators.viewRawAmount(
                    curve.assets[i].addr,
                    __deposit.mul(curve.weights[i]).add(ONE_WEI)
                );
            }
        } else {
            // We already have an existing pool ratio
            // this must be respected
            int128 _multiplier = __deposit.div(_oGLiq);

            uint256 _baseWeight = curve.weights[0].mulu(1e18);
            uint256 _quoteWeight = curve.weights[1].mulu(1e18);

            // Deposits into the pool is determined by existing LP ratio
            for (uint256 i = 0; i < _length; i++) {
                deposits_[i] = Assimilators.viewRawAmountLPRatio(
                    curve.assets[i].addr,
                    _baseWeight,
                    _quoteWeight,
                    _oBals[i].mul(_multiplier).add(ONE_WEI)
                );
            }
        }

        int128 _totalShells = curve.totalSupply.divu(1e18);

        int128 _newShells = __deposit;

        if (_totalShells > 0) {
            _newShells = __deposit.mul(_totalShells);
            _newShells = _newShells.div(_oGLiq);
        }

        curves_ = _newShells.mulu(1e18);

        return (curves_, deposits_);
    }

    function proportionalWithdraw(
        Storage.Curve storage curve,
        uint256 _withdrawal,
        bool _toETH
    ) external returns (uint256[] memory) {
        uint256 _length = curve.assets.length;

        (, int128[] memory _oBals) = getGrossLiquidityAndBalances(curve);

        uint256[] memory withdrawals_ = new uint256[](_length);

        int128 _totalShells = curve.totalSupply.divu(1e18);
        int128 __withdrawal = _withdrawal.divu(1e18);

        int128 _multiplier = __withdrawal.div(_totalShells);

        for (uint256 i = 0; i < _length; i++) {
            if (
                _toETH &&
                (IAssimilator(curve.assets[i].addr).underlyingToken() ==
                    IAssimilator(curve.assets[i].addr).getWeth())
            ) {
                withdrawals_[i] = Assimilators.outputNumeraire(
                    curve.assets[i].addr,
                    msg.sender,
                    _oBals[i].mul(_multiplier),
                    true
                );
            } else
                withdrawals_[i] = Assimilators.outputNumeraire(
                    curve.assets[i].addr,
                    msg.sender,
                    _oBals[i].mul(_multiplier),
                    false
                );
        }

        burn(curve, msg.sender, _withdrawal);

        return withdrawals_;
    }

    function viewProportionalWithdraw(
        Storage.Curve storage curve,
        uint256 _withdrawal
    ) external view returns (uint256[] memory) {
        uint256 _length = curve.assets.length;

        (, int128[] memory _oBals) = getGrossLiquidityAndBalances(curve);

        uint256[] memory withdrawals_ = new uint256[](_length);

        int128 _multiplier = _withdrawal.divu(1e18).div(
            curve.totalSupply.divu(1e18)
        );

        for (uint256 i = 0; i < _length; i++) {
            withdrawals_[i] = Assimilators.viewRawAmount(
                curve.assets[i].addr,
                _oBals[i].mul(_multiplier)
            );
        }

        return withdrawals_;
    }

    function getGrossLiquidityAndBalancesForDeposit(
        Storage.Curve storage curve
    ) internal view returns (int128 grossLiquidity_, int128[] memory) {
        uint256 _length = curve.assets.length;

        int128[] memory balances_ = new int128[](_length);
        uint256 _baseWeight = curve.weights[0].mulu(1e18);
        uint256 _quoteWeight = curve.weights[1].mulu(1e18);

        for (uint256 i = 0; i < _length; i++) {
            int128 _bal = Assimilators.viewNumeraireBalanceLPRatio(
                _baseWeight,
                _quoteWeight,
                curve.assets[i].addr
            );

            balances_[i] = _bal;
            grossLiquidity_ += _bal;
        }

        return (grossLiquidity_, balances_);
    }

    function getGrossLiquidityAndBalances(
        Storage.Curve storage curve
    ) internal view returns (int128 grossLiquidity_, int128[] memory) {
        uint256 _length = curve.assets.length;

        int128[] memory balances_ = new int128[](_length);

        for (uint256 i = 0; i < _length; i++) {
            int128 _bal = Assimilators.viewNumeraireBalance(
                curve.assets[i].addr
            );

            balances_[i] = _bal;
            grossLiquidity_ += _bal;
        }

        return (grossLiquidity_, balances_);
    }

    function burn(
        Storage.Curve storage curve,
        address account,
        uint256 amount
    ) private {
        curve.balances[account] = burnSub(curve.balances[account], amount);

        curve.totalSupply = burnSub(curve.totalSupply, amount);

        emit Transfer(msg.sender, address(0), amount);
    }

    function mint(
        Storage.Curve storage curve,
        address account,
        uint256 amount
    ) private {
        uint256 minLock = 1e6;
        if (curve.totalSupply == 0) {
            require(
                amount > minLock,
                "Proportional Liquidity/amount too small!"
            );
            uint256 toMintAmt = amount - minLock;
            // mint to lp provider
            curve.totalSupply = mintAdd(curve.totalSupply, toMintAmt);
            curve.balances[account] = mintAdd(
                curve.balances[account],
                toMintAmt
            );
            emit Transfer(address(0), msg.sender, toMintAmt);
            // mint to 0 address
            curve.totalSupply = mintAdd(curve.totalSupply, minLock);
            curve.balances[address(0)] = mintAdd(
                curve.balances[address(0)],
                minLock
            );
            emit Transfer(address(this), address(0), minLock);
        } else {
            curve.totalSupply = mintAdd(curve.totalSupply, amount);
            curve.balances[account] = mintAdd(curve.balances[account], amount);
            emit Transfer(address(0), msg.sender, amount);
        }
    }

    function mintAdd(uint256 x, uint256 y) private pure returns (uint256 z) {
        require((z = x + y) >= x, "Curve/mint-overflow");
    }

    function burnSub(uint256 x, uint256 y) private pure returns (uint256 z) {
        require((z = x - y) <= x, "Curve/burn-underflow");
    }
}

library Swaps {
    using ABDKMath64x64 for int128;
    using ABDKMath64x64 for int256;
    using UnsafeMath64x64 for int128;
    using ABDKMath64x64 for uint256;
    using SafeMath for uint256;

    event Trade(
        address indexed trader,
        address indexed origin,
        address indexed target,
        uint256 originAmount,
        uint256 targetAmount,
        int128 rawProtocolFee
    );

    int128 public constant ONE = 0x10000000000000000;

    function getOriginAndTarget(
        Storage.Curve storage curve,
        address _o,
        address _t
    )
        private
        view
        returns (Storage.Assimilator memory, Storage.Assimilator memory)
    {
        Storage.Assimilator memory o_ = curve.assimilators[_o];
        Storage.Assimilator memory t_ = curve.assimilators[_t];

        require(o_.addr != address(0), "Curve/origin-not-supported");
        require(t_.addr != address(0), "Curve/target-not-supported");

        return (o_, t_);
    }

    function originSwap(
        Storage.Curve storage curve,
        OriginSwapData memory _swapData,
        bool toETH
    ) external returns (uint256 tAmt_) {
        (
            Storage.Assimilator memory _o,
            Storage.Assimilator memory _t
        ) = getOriginAndTarget(curve, _swapData._origin, _swapData._target);

        if (_o.ix == _t.ix)
            return
                Assimilators.outputNumeraire(
                    _t.addr,
                    _swapData._recipient,
                    Assimilators.intakeRaw(_o.addr, _swapData._originAmount),
                    toETH
                );

        SwapInfo memory _swapInfo;
        (
            int128 _amt,
            int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _oBals,
            int128[] memory _nBals
        ) = getOriginSwapData(
                curve,
                _o.ix,
                _t.ix,
                _o.addr,
                _swapData._originAmount
            );

        _swapInfo.totalAmount = _amt;

        _amt = CurveMath.calculateTrade(
            curve,
            _oGLiq,
            _nGLiq,
            _oBals,
            _nBals,
            _amt,
            _t.ix
        );

        _swapInfo.curveFactory = ICurveFactory(_swapData._curveFactory);
        _swapInfo.amountToUser = _amt.us_mul(ONE - curve.epsilon);
        _swapInfo.totalFee = _swapInfo.amountToUser - _amt;
        _swapInfo.protocolFeePercentage = _swapInfo
            .curveFactory
            .getProtocolFee();
        _swapInfo.treasury = _swapInfo.curveFactory.getProtocolTreasury();
        _swapInfo.amountToTreasury = _swapInfo
            .totalFee
            .muli(_swapInfo.protocolFeePercentage)
            .divi(100000);
        Assimilators.transferFee(
            _t.addr,
            _swapInfo.amountToTreasury,
            _swapInfo.treasury
        );
        tAmt_ = Assimilators.outputNumeraire(
            _t.addr,
            _swapData._recipient,
            _swapInfo.amountToUser,
            toETH
        );

        emit Trade(
            msg.sender,
            _swapData._origin,
            _swapData._target,
            _swapData._originAmount,
            tAmt_,
            _swapInfo.amountToTreasury
        );
    }

    function viewOriginSwap(
        Storage.Curve storage curve,
        address _origin,
        address _target,
        uint256 _originAmount
    ) external view returns (uint256 tAmt_) {
        (
            Storage.Assimilator memory _o,
            Storage.Assimilator memory _t
        ) = getOriginAndTarget(curve, _origin, _target);

        if (_o.ix == _t.ix)
            return
                Assimilators.viewRawAmount(
                    _t.addr,
                    Assimilators.viewNumeraireAmount(_o.addr, _originAmount)
                );

        (
            int128 _amt,
            int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _nBals,
            int128[] memory _oBals
        ) = viewOriginSwapData(curve, _o.ix, _t.ix, _originAmount, _o.addr);

        _amt = CurveMath.calculateTrade(
            curve,
            _oGLiq,
            _nGLiq,
            _oBals,
            _nBals,
            _amt,
            _t.ix
        );

        _amt = _amt.us_mul(ONE - curve.epsilon);

        tAmt_ = Assimilators.viewRawAmount(_t.addr, _amt.abs());
    }

    function targetSwap(
        Storage.Curve storage curve,
        TargetSwapData memory _swapData
    ) external returns (uint256 oAmt_) {
        (
            Storage.Assimilator memory _o,
            Storage.Assimilator memory _t
        ) = getOriginAndTarget(curve, _swapData._origin, _swapData._target);

        if (_o.ix == _t.ix)
            return
                Assimilators.intakeNumeraire(
                    _o.addr,
                    Assimilators.outputRaw(
                        _t.addr,
                        _swapData._recipient,
                        _swapData._targetAmount
                    )
                );

        (
            int128 _amt,
            int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _oBals,
            int128[] memory _nBals
        ) = getTargetSwapData(
                curve,
                _t.ix,
                _o.ix,
                _t.addr,
                _swapData._recipient,
                _swapData._targetAmount
            );

        _amt = CurveMath.calculateTrade(
            curve,
            _oGLiq,
            _nGLiq,
            _oBals,
            _nBals,
            _amt,
            _o.ix
        );

        SwapInfo memory _swapInfo;

        _swapInfo.totalAmount = _amt;
        _swapInfo.curveFactory = ICurveFactory(_swapData._curveFactory);
        _swapInfo.amountToUser = _amt.us_mul(ONE + curve.epsilon);
        _swapInfo.totalFee = _swapInfo.amountToUser - _amt;
        _swapInfo.protocolFeePercentage = _swapInfo
            .curveFactory
            .getProtocolFee();
        _swapInfo.treasury = _swapInfo.curveFactory.getProtocolTreasury();
        _swapInfo.amountToTreasury = _swapInfo
            .totalFee
            .muli(_swapInfo.protocolFeePercentage)
            .divi(100000);

        Assimilators.transferFee(
            _o.addr,
            _swapInfo.amountToTreasury,
            _swapInfo.treasury
        );

        oAmt_ = Assimilators.intakeNumeraire(_o.addr, _swapInfo.amountToUser);

        emit Trade(
            msg.sender,
            _swapData._origin,
            _swapData._target,
            oAmt_,
            _swapData._targetAmount,
            _swapInfo.amountToTreasury
        );
    }

    function viewTargetSwap(
        Storage.Curve storage curve,
        address _origin,
        address _target,
        uint256 _targetAmount
    ) external view returns (uint256 oAmt_) {
        (
            Storage.Assimilator memory _o,
            Storage.Assimilator memory _t
        ) = getOriginAndTarget(curve, _origin, _target);

        if (_o.ix == _t.ix)
            return
                Assimilators.viewRawAmount(
                    _o.addr,
                    Assimilators.viewNumeraireAmount(_t.addr, _targetAmount)
                );

        (
            int128 _amt,
            int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _nBals,
            int128[] memory _oBals
        ) = viewTargetSwapData(curve, _t.ix, _o.ix, _targetAmount, _t.addr);

        _amt = CurveMath.calculateTrade(
            curve,
            _oGLiq,
            _nGLiq,
            _oBals,
            _nBals,
            _amt,
            _o.ix
        );

        _amt = _amt.us_mul(ONE + curve.epsilon);

        oAmt_ = Assimilators.viewRawAmount(_o.addr, _amt);
    }

    function getOriginSwapData(
        Storage.Curve storage curve,
        uint256 _inputIx,
        uint256 _outputIx,
        address _assim,
        uint256 _amt
    )
        private
        returns (
            int128 amt_,
            int128 oGLiq_,
            int128 nGLiq_,
            int128[] memory,
            int128[] memory
        )
    {
        uint256 _length = curve.assets.length;

        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);
        Storage.Assimilator[] memory _reserves = curve.assets;

        for (uint256 i = 0; i < _length; i++) {
            if (i != _inputIx)
                nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(
                    _reserves[i].addr
                );
            else {
                int128 _bal;
                (amt_, _bal) = Assimilators.intakeRawAndGetBalance(
                    _assim,
                    _amt
                );

                oBals_[i] = _bal.sub(amt_);
                nBals_[i] = _bal;
            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];
        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);

        return (amt_, oGLiq_, nGLiq_, oBals_, nBals_);
    }

    function getTargetSwapData(
        Storage.Curve storage curve,
        uint256 _inputIx,
        uint256 _outputIx,
        address _assim,
        address _recipient,
        uint256 _amt
    )
        private
        returns (
            int128 amt_,
            int128 oGLiq_,
            int128 nGLiq_,
            int128[] memory,
            int128[] memory
        )
    {
        uint256 _length = curve.assets.length;

        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);
        Storage.Assimilator[] memory _reserves = curve.assets;

        for (uint256 i = 0; i < _length; i++) {
            if (i != _inputIx)
                nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(
                    _reserves[i].addr
                );
            else {
                int128 _bal;
                (amt_, _bal) = Assimilators.outputRawAndGetBalance(
                    _assim,
                    _recipient,
                    _amt
                );

                oBals_[i] = _bal.sub(amt_);
                nBals_[i] = _bal;
            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];
        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);

        return (amt_, oGLiq_, nGLiq_, oBals_, nBals_);
    }

    function viewOriginSwapData(
        Storage.Curve storage curve,
        uint256 _inputIx,
        uint256 _outputIx,
        uint256 _amt,
        address _assim
    )
        private
        view
        returns (
            int128 amt_,
            int128 oGLiq_,
            int128 nGLiq_,
            int128[] memory,
            int128[] memory
        )
    {
        uint256 _length = curve.assets.length;
        int128[] memory nBals_ = new int128[](_length);
        int128[] memory oBals_ = new int128[](_length);

        for (uint256 i = 0; i < _length; i++) {
            if (i != _inputIx)
                nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(
                    curve.assets[i].addr
                );
            else {
                int128 _bal;
                (amt_, _bal) = Assimilators.viewNumeraireAmountAndBalance(
                    _assim,
                    _amt
                );

                oBals_[i] = _bal;
                nBals_[i] = _bal.add(amt_);
            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];
        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);

        return (amt_, oGLiq_, nGLiq_, nBals_, oBals_);
    }

    function viewTargetSwapData(
        Storage.Curve storage curve,
        uint256 _inputIx,
        uint256 _outputIx,
        uint256 _amt,
        address _assim
    )
        private
        view
        returns (
            int128 amt_,
            int128 oGLiq_,
            int128 nGLiq_,
            int128[] memory,
            int128[] memory
        )
    {
        uint256 _length = curve.assets.length;
        int128[] memory nBals_ = new int128[](_length);
        int128[] memory oBals_ = new int128[](_length);

        for (uint256 i = 0; i < _length; i++) {
            if (i != _inputIx)
                nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(
                    curve.assets[i].addr
                );
            else {
                int128 _bal;
                (amt_, _bal) = Assimilators.viewNumeraireAmountAndBalance(
                    _assim,
                    _amt
                );
                amt_ = amt_.neg();

                oBals_[i] = _bal;
                nBals_[i] = _bal.add(amt_);
            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];
        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);

        return (amt_, oGLiq_, nGLiq_, nBals_, oBals_);
    }
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ViewLiquidity {
    using ABDKMath64x64 for int128;

    function viewLiquidity(
        Storage.Curve storage curve
    ) external view returns (uint256 total_, uint256[] memory individual_) {
        uint256 _length = curve.assets.length;

        individual_ = new uint256[](_length);

        for (uint256 i = 0; i < _length; i++) {
            uint256 _liquidity = Assimilators
                .viewNumeraireBalance(curve.assets[i].addr)
                .mulu(1e18);

            total_ += _liquidity;
            individual_[i] = _liquidity;
        }

        return (total_, individual_);
    }
}

interface ICurve {
    function getWeth() external view returns (address);
}

interface IConfig {
    function getGlobalFrozenState() external view returns (bool);

    function getProtocolFee() external view returns (int128);

    function getProtocolTreasury() external view returns (address);

    function setGlobalFrozen(bool) external;

    function toggleGlobalGuarded() external;

    function setPoolGuarded(address, bool) external;

    function setGlobalGuardAmount(uint256) external;

    function setPoolCap(address, uint256) external;

    function setPoolGuardAmount(address, uint256) external;

    function isPoolGuarded(address) external view returns (bool);

    function getPoolGuardAmount(address) external view returns (uint256);

    function getPoolCap(address) external view returns (uint256);

    function updateProtocolTreasury(address) external;

    function updateProtocolFee(int128) external;
}

library Curves {
    using ABDKMath64x64 for int128;

    event Approval(
        address indexed _owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function add(
        uint256 x,
        uint256 y,
        string memory errorMessage
    ) private pure returns (uint256 z) {
        require((z = x + y) >= x, errorMessage);
    }

    function sub(
        uint256 x,
        uint256 y,
        string memory errorMessage
    ) private pure returns (uint256 z) {
        require((z = x - y) <= x, errorMessage);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        Storage.Curve storage curve,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(curve, msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        Storage.Curve storage curve,
        address spender,
        uint256 amount
    ) external returns (bool) {
        _approve(curve, msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`
     */
    function transferFrom(
        Storage.Curve storage curve,
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(curve, sender, recipient, amount);
        _approve(
            curve,
            sender,
            msg.sender,
            sub(
                curve.allowances[sender][msg.sender],
                amount,
                "Curve/insufficient-allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        Storage.Curve storage curve,
        address spender,
        uint256 addedValue
    ) external returns (bool) {
        _approve(
            curve,
            msg.sender,
            spender,
            add(
                curve.allowances[msg.sender][spender],
                addedValue,
                "Curve/approval-overflow"
            )
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(
        Storage.Curve storage curve,
        address spender,
        uint256 subtractedValue
    ) external returns (bool) {
        _approve(
            curve,
            msg.sender,
            spender,
            sub(
                curve.allowances[msg.sender][spender],
                subtractedValue,
                "Curve/allowance-decrease-underflow"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is public function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        Storage.Curve storage curve,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        curve.balances[sender] = sub(
            curve.balances[sender],
            amount,
            "Curve/insufficient-balance"
        );
        curve.balances[recipient] = add(
            curve.balances[recipient],
            amount,
            "Curve/transfer-overflow"
        );
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `_owner`s tokens.
     *
     * This is public function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `_owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        Storage.Curve storage curve,
        address _owner,
        address spender,
        uint256 amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        curve.allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
}

contract Curve is Storage, NoDelegateCall, ICurve {
    using SafeMath for uint256;
    using ABDKMath64x64 for int128;
    using SafeERC20 for IERC20;

    address private curveFactory;
    address private immutable wETH;

    IConfig private config;
    event Approval(
        address indexed _owner,
        address indexed spender,
        uint256 value
    );

    event ParametersSet(
        uint256 alpha,
        uint256 beta,
        uint256 delta,
        uint256 epsilon,
        uint256 lambda
    );

    event AssetIncluded(
        address indexed numeraire,
        address indexed reserve,
        uint256 weight
    );

    event AssimilatorIncluded(
        address indexed derivative,
        address indexed numeraire,
        address indexed reserve,
        address assimilator
    );

    event PartitionRedeemed(
        address indexed token,
        address indexed redeemer,
        uint256 value
    );

    event OwnershipTransfered(
        address indexed previousOwner,
        address indexed newOwner
    );

    event FrozenSet(bool isFrozen);

    event EmergencyAlarm(bool isEmergency);

    event Trade(
        address indexed trader,
        address indexed origin,
        address indexed target,
        uint256 originAmount,
        uint256 targetAmount,
        int128 rawProtocolFee
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Flash(
        address indexed from,
        address indexed to,
        uint256 value0,
        uint256 value1,
        uint256 paid0,
        uint256 paid1
    );

    modifier onlyOwner() {
        require(
            msg.sender == owner || msg.sender == config.getProtocolTreasury(),
            "Curve/caller-is-not-owner"
        );
        _;
    }

    modifier nonReentrant() {
        require(notEntered, "Curve/re-entered");
        notEntered = false;
        _;
        notEntered = true;
    }

    modifier transactable() {
        require(!frozen, "Curve/frozen-only-allowing-proportional-withdraw");
        _;
    }

    modifier isEmergency() {
        require(
            emergency,
            "Curve/emergency-only-allowing-emergency-proportional-withdraw"
        );
        _;
    }

    modifier isNotEmergency() {
        require(
            !emergency,
            "Curve/emergency-only-allowing-emergency-proportional-withdraw"
        );
        _;
    }

    modifier deadline(uint256 _deadline) {
        require(block.timestamp < _deadline, "Curve/tx-deadline-passed");
        _;
    }

    modifier globallyTransactable() {
        require(
            !config.getGlobalFrozenState(),
            "Curve/frozen-globally-only-allowing-proportional-withdraw"
        );
        _;
    }

    modifier isDepositable(address pool, uint256 deposits) {
        {
            uint256 poolCap = config.getPoolCap(pool);
            uint256 supply = totalSupply();
            require(
                poolCap == 0 || supply.add(deposits) <= poolCap,
                "curve/exceeds pool cap"
            );
        }
        if (!config.isPoolGuarded(pool)) {
            _;
        } else {
            _;
            uint256 poolGuardAmt = config.getPoolGuardAmount(pool);
            require(
                curve.balances[msg.sender] <= poolGuardAmt,
                "curve/deposit-exceeds-guard-amt"
            );
        }
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address[] memory _assets,
        uint256[] memory _assetWeights,
        address _factory,
        address _config
    ) {
        require(_factory != address(0), "Curve/curve factory zero address!");
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        curveFactory = _factory;
        config = IConfig(_config);
        emit OwnershipTransfered(address(0), msg.sender);
        wETH = ICurveFactory(_factory).wETH();

        Orchestrator.initialize(
            curve,
            numeraires,
            reserves,
            derivatives,
            _assets,
            _assetWeights
        );
    }

    /// @notice sets the parameters for the pool
    /// @param _alpha the value for alpha (halt threshold) must be less than or equal to 1 and greater than 0
    /// @param _beta the value for beta must be less than alpha and greater than 0
    /// @param _feeAtHalt the maximum value for the fee at the halt point
    /// @param _epsilon the base fee for the pool
    /// @param _lambda the value for lambda must be less than or equal to 1 and greater than zero
    function setParams(
        uint256 _alpha,
        uint256 _beta,
        uint256 _feeAtHalt,
        uint256 _epsilon,
        uint256 _lambda
    ) external onlyOwner {
        Orchestrator.setParams(
            curve,
            _alpha,
            _beta,
            _feeAtHalt,
            _epsilon,
            _lambda
        );
    }

    function setAssimilator(
        address _baseCurrency,
        address _baseAssim,
        address _quoteCurrency,
        address _quoteAssim
    ) external onlyOwner {
        Orchestrator.setAssimilator(
            curve,
            _baseCurrency,
            _baseAssim,
            _quoteCurrency,
            _quoteAssim
        );
    }

    /// @notice excludes an assimilator from the curve
    /// @param _derivative the address of the assimilator to exclude
    function excludeDerivative(address _derivative) external onlyOwner {
        for (uint256 i = 0; i < numeraires.length; i++) {
            if (_derivative == numeraires[i])
                revert("Curve/cannot-delete-numeraire");
            if (_derivative == reserves[i])
                revert("Curve/cannot-delete-reserve");
        }

        delete curve.assimilators[_derivative];
    }

    /// @notice view the current parameters of the curve
    /// @return alpha_ the current alpha value
    ///  beta_ the current beta value
    ///  delta_ the current delta value
    ///  epsilon_ the current epsilon value
    ///  lambda_ the current lambda value
    ///  omega_ the current omega value
    function viewCurve()
        external
        view
        returns (
            uint256 alpha_,
            uint256 beta_,
            uint256 delta_,
            uint256 epsilon_,
            uint256 lambda_
        )
    {
        return Orchestrator.viewCurve(curve);
    }

    function setEmergency(bool _emergency) external onlyOwner {
        emit EmergencyAlarm(_emergency);

        emergency = _emergency;
    }

    function setFrozen(bool _toFreezeOrNotToFreeze) external onlyOwner {
        emit FrozenSet(_toFreezeOrNotToFreeze);

        frozen = _toFreezeOrNotToFreeze;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(
            _newOwner != address(0),
            "Curve/new-owner-cannot-be-zero-address"
        );

        emit OwnershipTransfered(owner, _newOwner);

        owner = _newOwner;
    }

    /// @notice swap a dynamic origin amount for a fixed target amount
    /// @param _origin the address of the origin
    /// @param _target the address of the target
    /// @param _originAmount the origin amount
    /// @param _minTargetAmount the minimum target amount
    /// @param _deadline deadline in block number after which the trade will not execute
    /// @return targetAmount_ the amount of target that has been swapped for the origin amount
    function originSwap(
        address _origin,
        address _target,
        uint256 _originAmount,
        uint256 _minTargetAmount,
        uint256 _deadline
    )
        external
        deadline(_deadline)
        globallyTransactable
        transactable
        noDelegateCall
        isNotEmergency
        nonReentrant
        returns (uint256 targetAmount_)
    {
        OriginSwapData memory _swapData;
        _swapData._origin = _origin;
        _swapData._target = _target;
        _swapData._originAmount = _originAmount;
        _swapData._recipient = msg.sender;
        _swapData._curveFactory = curveFactory;
        targetAmount_ = Swaps.originSwap(curve, _swapData, false);

        require(
            targetAmount_ >= _minTargetAmount,
            "Curve/below-min-target-amount"
        );
    }

    function originSwapFromETH(
        address _target,
        uint256 _minTargetAmount,
        uint256 _deadline
    )
        external
        payable
        deadline(_deadline)
        globallyTransactable
        transactable
        noDelegateCall
        isNotEmergency
        nonReentrant
        returns (uint256 targetAmount_)
    {
        // first convert coming ETH to WETH & send wrapped amount to user back
        IWETH(wETH).deposit{value: msg.value}();
        IERC20(wETH).safeTransferFrom(address(this), msg.sender, msg.value);
        OriginSwapData memory _swapData;
        _swapData._origin = wETH;
        _swapData._target = _target;
        _swapData._originAmount = msg.value;
        _swapData._recipient = msg.sender;
        _swapData._curveFactory = curveFactory;
        targetAmount_ = Swaps.originSwap(curve, _swapData, false);

        require(
            targetAmount_ >= _minTargetAmount,
            "Curve/below-min-target-amount"
        );
    }

    function originSwapToETH(
        address _origin,
        uint256 _originAmount,
        uint256 _minTargetAmount,
        uint256 _deadline
    )
        external
        deadline(_deadline)
        globallyTransactable
        transactable
        noDelegateCall
        isNotEmergency
        nonReentrant
        returns (uint256 targetAmount_)
    {
        OriginSwapData memory _swapData;
        _swapData._origin = _origin;
        _swapData._target = wETH;
        _swapData._originAmount = _originAmount;
        _swapData._recipient = msg.sender;
        _swapData._curveFactory = curveFactory;
        targetAmount_ = Swaps.originSwap(curve, _swapData, true);

        require(
            targetAmount_ >= _minTargetAmount,
            "Curve/below-min-target-amount"
        );
    }

    /// @notice view how much target amount a fixed origin amount will swap for
    /// @param _origin the address of the origin
    /// @param _target the address of the target
    /// @param _originAmount the origin amount
    /// @return targetAmount_ the target amount that would have been swapped for the origin amount
    function viewOriginSwap(
        address _origin,
        address _target,
        uint256 _originAmount
    )
        external
        view
        globallyTransactable
        transactable
        returns (uint256 targetAmount_)
    {
        targetAmount_ = Swaps.viewOriginSwap(
            curve,
            _origin,
            _target,
            _originAmount
        );
    }

    /// @notice swap a dynamic origin amount for a fixed target amount
    /// @param _origin the address of the origin
    /// @param _target the address of the target
    /// @param _maxOriginAmount the maximum origin amount
    /// @param _targetAmount the target amount
    /// @param _deadline deadline in block number after which the trade will not execute
    /// @return originAmount_ the amount of origin that has been swapped for the target
    function targetSwap(
        address _origin,
        address _target,
        uint256 _maxOriginAmount,
        uint256 _targetAmount,
        uint256 _deadline
    )
        external
        deadline(_deadline)
        globallyTransactable
        transactable
        noDelegateCall
        isNotEmergency
        nonReentrant
        returns (uint256 originAmount_)
    {
        TargetSwapData memory _swapData;
        _swapData._origin = _origin;
        _swapData._target = _target;
        _swapData._targetAmount = _targetAmount;
        _swapData._recipient = msg.sender;
        _swapData._curveFactory = curveFactory;
        originAmount_ = Swaps.targetSwap(curve, _swapData);
        // originAmount_ = Swaps.targetSwap(curve, _origin, _target, _targetAmount, msg.sender,curveFactory);

        require(
            originAmount_ <= _maxOriginAmount,
            "Curve/above-max-origin-amount"
        );
    }

    /// @notice view how much of the origin currency the target currency will take
    /// @param _origin the address of the origin
    /// @param _target the address of the target
    /// @param _targetAmount the target amount
    /// @return originAmount_ the amount of target that has been swapped for the origin
    function viewTargetSwap(
        address _origin,
        address _target,
        uint256 _targetAmount
    )
        external
        view
        globallyTransactable
        transactable
        returns (uint256 originAmount_)
    {
        originAmount_ = Swaps.viewTargetSwap(
            curve,
            _origin,
            _target,
            _targetAmount
        );
    }

    /// @notice deposit into the pool with no slippage from the numeraire assets the pool supports
    /// @param  _deposit the full amount you want to deposit into the pool which will be divided up evenly amongst
    ///                  the numeraire assets of the pool
    /// @return ( the amount of curves you receive in return for your deposit,
    ///           the amount deposited for each numeraire)
    function deposit(
        uint256 _deposit,
        uint256 _minQuoteAmount,
        uint256 _minBaseAmount,
        uint256 _maxQuoteAmount,
        uint256 _maxBaseAmount,
        uint256 _deadline
    )
        external
        deadline(_deadline)
        globallyTransactable
        transactable
        nonReentrant
        noDelegateCall
        isNotEmergency
        isDepositable(address(this), _deposit)
        returns (uint256, uint256[] memory)
    {
        require(_deposit > 0, "Curve/deposit_below_zero");

        // (curvesMinted_,  deposits_)
        DepositData memory _depositData;
        _depositData.deposits = _deposit;
        _depositData.minQuote = _minQuoteAmount;
        _depositData.minBase = _minBaseAmount;
        _depositData.maxQuote = _maxQuoteAmount;
        _depositData.maxBase = _maxBaseAmount;
        (
            uint256 curvesMinted_,
            uint256[] memory deposits_
        ) = ProportionalLiquidity.proportionalDeposit(curve, _depositData);
        return (curvesMinted_, deposits_);
    }

    // deposit in ETH
    function depositETH(
        uint256 _deposit,
        uint256 _minQuoteAmount,
        uint256 _minBaseAmount,
        uint256 _maxQuoteAmount,
        uint256 _maxBaseAmount,
        uint256 _deadline
    )
        external
        payable
        deadline(_deadline)
        globallyTransactable
        transactable
        nonReentrant
        noDelegateCall
        isNotEmergency
        isDepositable(address(this), _deposit)
        returns (uint256, uint256[] memory)
    {
        require(_deposit > 0, "Curve/deposit_below_zero");

        // (curvesMinted_,  deposits_)
        IWETH(wETH).deposit{value: msg.value}();
        IERC20(wETH).safeTransferFrom(address(this), msg.sender, msg.value);
        DepositData memory _depositData;
        _depositData.deposits = _deposit;
        _depositData.minQuote = _minQuoteAmount;
        _depositData.minBase = _minBaseAmount;
        _depositData.maxQuote = _maxQuoteAmount;
        _depositData.maxBase = _maxBaseAmount;
        (
            uint256 curvesMinted_,
            uint256[] memory deposits_
        ) = ProportionalLiquidity.proportionalDeposit(curve, _depositData);

        uint256 remainder = 0;
        if (IAssimilator(curve.assets[0].addr).underlyingToken() == wETH) {
            remainder = msg.value - deposits_[0];
        } else if (
            IAssimilator(curve.assets[1].addr).underlyingToken() == wETH
        ) {
            remainder = msg.value - deposits_[1];
        } else {
            revert("reverted here");
        }
        // now need to determine which is wETH
        if (remainder > 0) {
            IERC20(wETH).safeTransferFrom(
                msg.sender,
                address(this),
                msg.value - deposits_[0]
            );
            IWETH(wETH).withdraw(remainder);
            (bool success, ) = msg.sender.call{value: remainder}("");
            require(success, "Curve/ETH transfer failed");
        }
        return (curvesMinted_, deposits_);
    }

    /// @notice view deposits and curves minted a given deposit would return
    /// @param _deposit the full amount of stablecoins you want to deposit. Divided evenly according to the
    ///                 prevailing proportions of the numeraire assets of the pool
    /// @return (the amount of curves you receive in return for your deposit,
    ///          the amount deposited for each numeraire)
    function viewDeposit(
        uint256 _deposit
    )
        external
        view
        globallyTransactable
        transactable
        returns (uint256, uint256[] memory)
    {
        // curvesToMint_, depositsToMake_
        return ProportionalLiquidity.viewProportionalDeposit(curve, _deposit);
    }

    /// @notice  Emergency withdraw tokens in the event that the oracle somehow bugs out
    ///          and no one is able to withdraw due to the invariant check
    /// @param   _curvesToBurn the full amount you want to withdraw from the pool which will be withdrawn from evenly amongst the
    ///                        numeraire assets of the pool
    /// @return withdrawals_ the amonts of numeraire assets withdrawn from the pool
    function emergencyWithdraw(
        uint256 _curvesToBurn,
        uint256 _deadline
    )
        external
        isEmergency
        deadline(_deadline)
        nonReentrant
        noDelegateCall
        returns (uint256[] memory withdrawals_)
    {
        return
            ProportionalLiquidity.proportionalWithdraw(
                curve,
                _curvesToBurn,
                false
            );
    }

    /// @notice  withdrawas amount of curve tokens from the the pool equally from the numeraire assets of the pool with no slippage
    /// @param   _curvesToBurn the full amount you want to withdraw from the pool which will be withdrawn from evenly amongst the
    ///                        numeraire assets of the pool
    /// @return withdrawals_ the amonts of numeraire assets withdrawn from the pool
    function withdraw(
        uint256 _curvesToBurn,
        uint256 _deadline
    )
        external
        deadline(_deadline)
        nonReentrant
        noDelegateCall
        isNotEmergency
        returns (uint256[] memory withdrawals_)
    {
        return
            ProportionalLiquidity.proportionalWithdraw(
                curve,
                _curvesToBurn,
                false
            );
    }

    /// @notice  withdrawas amount of curve tokens from the the pool equally from the numeraire assets of the pool with no slippage, WETH is unwrapped to ETH
    /// @param   _curvesToBurn the full amount you want to withdraw from the pool which will be withdrawn from evenly amongst the
    ///                        numeraire assets of the pool
    /// @return withdrawals_ the amonts of numeraire assets withdrawn from the pool
    function withdrawETH(
        uint256 _curvesToBurn,
        uint256 _deadline
    )
        external
        deadline(_deadline)
        nonReentrant
        noDelegateCall
        isNotEmergency
        returns (uint256[] memory withdrawals_)
    {
        return
            ProportionalLiquidity.proportionalWithdraw(
                curve,
                _curvesToBurn,
                true
            );
    }

    /// @notice  views the withdrawal information from the pool
    /// @param   _curvesToBurn the full amount you want to withdraw from the pool which will be withdrawn from evenly amongst the
    ///                        numeraire assets of the pool
    /// @return the amonnts of numeraire assets withdrawn from the pool
    function viewWithdraw(
        uint256 _curvesToBurn
    )
        external
        view
        globallyTransactable
        transactable
        returns (uint256[] memory)
    {
        return
            ProportionalLiquidity.viewProportionalWithdraw(
                curve,
                _curvesToBurn
            );
    }

    function getWeth() external view override returns (address) {
        return wETH;
    }

    function supportsInterface(
        bytes4 _interface
    ) public pure returns (bool supports_) {
        supports_ =
            this.supportsInterface.selector == _interface || // erc165
            bytes4(0x7f5828d0) == _interface || // eip173
            bytes4(0x36372b07) == _interface; // erc20
    }

    /// @notice transfers curve tokens
    /// @param _recipient the address of where to send the curve tokens
    /// @param _amount the amount of curve tokens to send
    /// @return success_ the success bool of the call
    function transfer(
        address _recipient,
        uint256 _amount
    )
        public
        nonReentrant
        noDelegateCall
        isNotEmergency
        returns (bool success_)
    {
        success_ = Curves.transfer(curve, _recipient, _amount);
    }

    /// @notice transfers curve tokens from one address to another address
    /// @param _sender the account from which the curve tokens will be sent
    /// @param _recipient the account to which the curve tokens will be sent
    /// @param _amount the amount of curve tokens to transfer
    /// @return success_ the success bool of the call
    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        public
        nonReentrant
        noDelegateCall
        isNotEmergency
        returns (bool success_)
    {
        success_ = Curves.transferFrom(curve, _sender, _recipient, _amount);
    }

    /// @notice approves a user to spend curve tokens on their behalf
    /// @param _spender the account to allow to spend from msg.sender
    /// @param _amount the amount to specify the spender can spend
    /// @return success_ the success bool of this call
    function approve(
        address _spender,
        uint256 _amount
    ) public nonReentrant noDelegateCall returns (bool success_) {
        success_ = Curves.approve(curve, _spender, _amount);
    }

    /// @notice view the curve token balance of a given account
    /// @param _account the account to view the balance of
    /// @return balance_ the curve token ballance of the given account
    function balanceOf(
        address _account
    ) public view returns (uint256 balance_) {
        balance_ = curve.balances[_account];
    }

    /// @notice views the total curve supply of the pool
    /// @return totalSupply_ the total supply of curve tokens
    function totalSupply() public view returns (uint256 totalSupply_) {
        totalSupply_ = curve.totalSupply;
    }

    /// @notice views the total allowance one address has to spend from another address
    /// @param _owner the address of the owner
    /// @param _spender the address of the spender
    /// @return allowance_ the amount the owner has allotted the spender
    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 allowance_) {
        allowance_ = curve.allowances[_owner][_spender];
    }

    /// @notice views the total amount of liquidity in the curve in numeraire value and format - 18 decimals
    /// @return total_ the total value in the curve
    /// @return individual_ the individual values in the curve
    function liquidity()
        public
        view
        returns (uint256 total_, uint256[] memory individual_)
    {
        return ViewLiquidity.viewLiquidity(curve);
    }

    /// @notice view the assimilator address for a derivative
    /// @return assimilator_ the assimilator address
    function assimilator(
        address _derivative
    ) public view returns (address assimilator_) {
        assimilator_ = curve.assimilators[_derivative].addr;
    }

    receive() external payable {}
}

contract AssimilatorFactory is IAssimilatorFactory {
    using Address for address;

    event NewAssimilator(
        address indexed caller,
        bytes32 indexed id,
        address indexed assimilator,
        address oracle,
        address token,
        address quote
    );
    event AssimilatorRevoked(
        address indexed caller,
        bytes32 indexed id,
        address indexed assimilator
    );
    event CurveFactoryUpdated(
        address indexed caller,
        address indexed curveFactory
    );
    mapping(bytes32 => AssimilatorV2) public assimilators;

    address public curveFactory;
    address public config;

    modifier onlyCurveFactoryOrOwner() {
        require(
            msg.sender == curveFactory || msg.sender == owner(),
            "unauthorized"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            msg.sender == IConfig(config).getProtocolTreasury(),
            "unauthorized"
        );
        _;
    }

    constructor(address _config) {
        require(_config.isContract(), "AssimFactory/invalid-config-address");
        config = _config;
    }

    function owner() public view returns (address) {
        return IConfig(config).getProtocolTreasury();
    }

    function setCurveFactory(address _curveFactory) external onlyOwner {
        require(
            _curveFactory != address(0),
            "AssimFactory/curve factory zero address!"
        );
        curveFactory = _curveFactory;
        emit CurveFactoryUpdated(msg.sender, curveFactory);
    }

    function getAssimilator(
        address _token,
        address _quote
    ) external view override returns (AssimilatorV2) {
        bytes32 assimilatorID = keccak256(abi.encode(_token, _quote));
        return assimilators[assimilatorID];
    }

    function newAssimilator(
        address _quote,
        IOracle _oracle,
        address _token,
        uint256 _tokenDecimals
    ) external override onlyCurveFactoryOrOwner returns (AssimilatorV2) {
        require(
            curveFactory != address(0),
            "AssimFactory/Curve-Factory-Not-Set"
        );
        bytes32 assimilatorID = keccak256(abi.encode(_token, _quote));
        if (address(assimilators[assimilatorID]) != address(0))
            revert("AssimilatorFactory/assimilator-already-exists");
        AssimilatorV2 assimilator = new AssimilatorV2(
            ICurveFactory(curveFactory).wETH(),
            _quote,
            _oracle,
            _token,
            _tokenDecimals,
            IOracle(_oracle).decimals()
        );
        assimilators[assimilatorID] = assimilator;
        emit NewAssimilator(
            msg.sender,
            assimilatorID,
            address(assimilator),
            address(_oracle),
            _token,
            _quote
        );
        return assimilator;
    }

    function revokeAssimilator(
        address _token,
        address _quote
    ) external onlyOwner {
        bytes32 assimilatorID = keccak256(abi.encode(_token, _quote));
        address _assimAddress = address(assimilators[assimilatorID]);
        assimilators[assimilatorID] = AssimilatorV2(address(0));
        emit AssimilatorRevoked(
            msg.sender,
            assimilatorID,
            address(_assimAddress)
        );
    }
}

contract CurveFactoryV2 is ICurveFactory, Ownable {
    using Address for address;

    IAssimilatorFactory public immutable assimilatorFactory;
    IConfig public config;

    event NewCurve(
        address indexed caller,
        bytes32 indexed id,
        address indexed curve
    );

    mapping(bytes32 => address) public curves;

    mapping(address => bool) public isDFXCurve;

    address public immutable wETH;

    constructor(address _assimFactory, address _config, address _weth) {
        require(
            _assimFactory.isContract(),
            "CurveFactory/invalid-assimFactory"
        );
        assimilatorFactory = IAssimilatorFactory(_assimFactory);
        require(_config.isContract(), "CurveFactory/invalid-config");
        config = IConfig(_config);
        wETH = _weth;
    }

    // function getGlobalFrozenState()
    //     external
    //     view
    //     virtual
    //     override
    //     returns (bool)
    // {
    //     return config.getGlobalFrozenState();
    // }

    // function getFlashableState() external view virtual override returns (bool) {
    //     return config.getFlashableState();
    // }

    function getProtocolFee() external view virtual override returns (int128) {
        return config.getProtocolFee();
    }

    function getProtocolTreasury()
        public
        view
        virtual
        override
        returns (address)
    {
        return config.getProtocolTreasury();
    }

    function getCurve(
        address _baseCurrency,
        address _quoteCurrency
    ) external view returns (address payable) {
        bytes32 curveId = keccak256(abi.encode(_baseCurrency, _quoteCurrency));
        return payable(curves[curveId]);
    }

    function newCurve(CurveInfo memory _info) public returns (Curve) {
        require(
            _info._quoteCurrency != address(0),
            "CurveFactory/quote-currency-zero-address"
        );
        require(
            _info._baseCurrency != _info._quoteCurrency,
            "CurveFactory/quote-base-currencies-same"
        );
        require(
            (_info._baseWeight + _info._quoteWeight) == 1e18,
            "CurveFactory/invalid-weights"
        );

        uint256 quoteDec = IERC20Detailed(_info._quoteCurrency).decimals();
        uint256 baseDec = IERC20Detailed(_info._baseCurrency).decimals();

        CurveIDPair memory idPair = generateCurveID(
            _info._baseCurrency,
            _info._quoteCurrency
        );
        if (
            curves[idPair.curveId] != address(0) ||
            curves[idPair.curveIdReversed] != address(0)
        ) revert("CurveFactory/pair-exists");
        AssimilatorV2 _baseAssim;
        _baseAssim = (
            assimilatorFactory.getAssimilator(
                _info._baseCurrency,
                _info._quoteCurrency
            )
        );
        if (address(_baseAssim) == address(0))
            _baseAssim = assimilatorFactory.newAssimilator(
                _info._quoteCurrency,
                _info._baseOracle,
                _info._baseCurrency,
                baseDec
            );
        AssimilatorV2 _quoteAssim;
        _quoteAssim = (
            assimilatorFactory.getAssimilator(
                _info._quoteCurrency,
                _info._baseCurrency
            )
        );
        if (address(_quoteAssim) == address(0))
            _quoteAssim = assimilatorFactory.newAssimilator(
                _info._baseCurrency,
                _info._quoteOracle,
                _info._quoteCurrency,
                quoteDec
            );

        address[] memory _assets = new address[](10);
        uint256[] memory _assetWeights = new uint256[](2);

        // Base Currency
        _assets[0] = _info._baseCurrency;
        _assets[1] = address(_baseAssim);
        _assets[2] = _info._baseCurrency;
        _assets[3] = address(_baseAssim);
        _assets[4] = _info._baseCurrency;

        // Quote Currency (typically USDC)
        _assets[5] = _info._quoteCurrency;
        _assets[6] = address(_quoteAssim);
        _assets[7] = _info._quoteCurrency;
        _assets[8] = address(_quoteAssim);
        _assets[9] = _info._quoteCurrency;

        // Weights
        _assetWeights[0] = _info._baseWeight;
        _assetWeights[1] = _info._quoteWeight;

        // New curve
        Curve curve = new Curve(
            _info._name,
            _info._symbol,
            _assets,
            _assetWeights,
            address(this),
            address(config)
        );
        curve.setParams(
            _info._alpha,
            _info._beta,
            _info._feeAtHalt,
            _info._epsilon,
            _info._lambda
        );
        curves[idPair.curveId] = address(curve);
        curves[idPair.curveIdReversed] = address(curve);
        isDFXCurve[address(curve)] = true;

        emit NewCurve(msg.sender, idPair.curveId, address(curve));

        return curve;
    }

    function generateCurveID(
        address _base,
        address _quote
    ) private pure returns (CurveIDPair memory) {
        CurveIDPair memory pair;
        pair.curveId = keccak256(abi.encode(_base, _quote));
        pair.curveIdReversed = keccak256(abi.encode(_quote, _base));
        return pair;
    }
}

// Simplistic router that assumes USD is the only quote currency for
contract Router {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public factory;
    address private immutable _wETH;

    constructor(address _factory) {
        require(_factory != address(0), "Curve/factory-cannot-be-zero-address");
        factory = _factory;
        _wETH = ICurveFactory(factory).wETH();
    }

    /// @notice view how much target amount a fixed origin amount will swap for
    /// @param _path the path to swap from origin to target
    /// @param _originAmount the origin amount
    /// @return targetAmount_ the amount of target that will be returned
    function viewOriginSwap(
        address[] memory _path,
        uint256 _originAmount
    ) external view returns (uint256 targetAmount_) {
        uint256 pathLen = _path.length;
        for (uint i = 0; i < pathLen - 1; ++i) {
            address payable curve = CurveFactoryV2(factory).getCurve(
                _path[i],
                _path[i + 1]
            );
            if (i == 0)
                targetAmount_ = Curve(curve).viewOriginSwap(
                    _path[i],
                    _path[i + 1],
                    _originAmount
                );
            else
                targetAmount_ = Curve(curve).viewOriginSwap(
                    _path[i],
                    _path[i + 1],
                    targetAmount_
                );
        }
    }

    function originSwap(
        uint256 _originAmount,
        uint256 _minTargetAmount,
        address[] memory _path,
        uint256 _deadline
    ) public returns (uint256 targetAmount_) {
        uint256 pathLen = _path.length;
        address origin = _path[0];
        address target = _path[pathLen - 1];
        IERC20(origin).safeTransferFrom(
            msg.sender,
            address(this),
            _originAmount
        );
        for (uint i = 0; i < pathLen - 1; ++i) {
            address payable curve = CurveFactoryV2(factory).getCurve(
                _path[i],
                _path[i + 1]
            );
            uint256 originBalance = IERC20(_path[i]).balanceOf(address(this));
            IERC20(_path[i]).safeApprove(curve, originBalance);
            targetAmount_ = Curve(curve).originSwap(
                _path[i],
                _path[i + 1],
                originBalance,
                0,
                _deadline
            );
        }
        require(targetAmount_ >= _minTargetAmount, "Router/originswap-failure");
        IERC20(target).safeTransfer(msg.sender, targetAmount_);
    }

    function originSwapFromETH(
        uint256 _minTargetAmount,
        address[] memory _path,
        uint256 _deadline
    ) public payable returns (uint256 targetAmount_) {
        // wrap ETH to WETH
        IWETH(_wETH).deposit{value: msg.value}();
        uint256 pathLen = _path.length;
        address origin = _path[0];
        require(origin == _wETH, "router/invalid-path");
        address target = _path[pathLen - 1];
        for (uint i = 0; i < pathLen - 1; ++i) {
            address payable curve = CurveFactoryV2(factory).getCurve(
                _path[i],
                _path[i + 1]
            );
            uint256 originBalance = IERC20(_path[i]).balanceOf(address(this));
            IERC20(_path[i]).safeApprove(curve, originBalance);
            targetAmount_ = Curve(curve).originSwap(
                _path[i],
                _path[i + 1],
                originBalance,
                0,
                _deadline
            );
        }
        require(
            targetAmount_ >= _minTargetAmount,
            "Router/originswap-from-ETH-failure"
        );
        IERC20(target).safeTransfer(msg.sender, targetAmount_);
    }

    function originSwapToETH(
        uint256 _originAmount,
        uint256 _minTargetAmount,
        address[] memory _path,
        uint256 _deadline
    ) public returns (uint256 targetAmount_) {
        uint256 pathLen = _path.length;
        address origin = _path[0];
        address target = _path[pathLen - 1];
        require(target == _wETH, "router/invalid-path");
        IERC20(origin).safeTransferFrom(
            msg.sender,
            address(this),
            _originAmount
        );
        for (uint i = 0; i < pathLen - 1; ++i) {
            address payable curve = CurveFactoryV2(factory).getCurve(
                _path[i],
                _path[i + 1]
            );
            uint256 originBalance = IERC20(_path[i]).balanceOf(address(this));
            IERC20(_path[i]).safeApprove(curve, originBalance);
            targetAmount_ = Curve(curve).originSwap(
                _path[i],
                _path[i + 1],
                originBalance,
                0,
                _deadline
            );
        }
        require(
            targetAmount_ >= _minTargetAmount,
            "Router/originswap-to-ETH-failure"
        );
        IWETH(_wETH).withdraw(targetAmount_);
        (bool success, ) = payable(msg.sender).call{value: targetAmount_}("");
        require(success, "router/eth-tranfer-failed");
    }

    /// @notice view how much of the origin currency the target currency will take
    /// @param _quoteCurrency the address of the quote currency (usually USDC)
    /// @param _origin the address of the origin
    /// @param _target the address of the target
    /// @param _targetAmount the target amount
    /// @return originAmount_ the amount of target that has been swapped for the origin
    function viewTargetSwap(
        address _quoteCurrency,
        address _origin,
        address _target,
        uint256 _targetAmount
    ) public view returns (uint256 originAmount_) {
        // If its an immediate pair then just swap directly on it
        address payable curve0 = CurveFactoryV2(factory).getCurve(
            _origin,
            _target
        );
        if (_origin == _quoteCurrency) {
            curve0 = CurveFactoryV2(factory).getCurve(_target, _origin);
        }

        if (curve0 != address(0)) {
            originAmount_ = Curve(curve0).viewTargetSwap(
                _origin,
                _target,
                _targetAmount
            );
            return originAmount_;
        }

        // Otherwise go through the quote currency
        curve0 = CurveFactoryV2(factory).getCurve(_target, _quoteCurrency);
        address payable curve1 = CurveFactoryV2(factory).getCurve(
            _origin,
            _quoteCurrency
        );
        if (curve0 != address(0) && curve1 != address(0)) {
            uint256 _quoteAmount = Curve(curve0).viewTargetSwap(
                _quoteCurrency,
                _target,
                _targetAmount
            );
            originAmount_ = Curve(curve1).viewTargetSwap(
                _origin,
                _quoteCurrency,
                _quoteAmount
            );
            return originAmount_;
        }

        revert("Router/No-path");
    }

    receive() external payable {}
}