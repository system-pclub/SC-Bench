// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

/**
 * @dev String operations.
 */

library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = sqrt(a);
            return
                result +
                (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = log2(value);
            return
                result +
                (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = log10(value);
            return
                result +
                (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex strings.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = log256(value);
            return
                result +
                (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    value < 0 ? "-" : "",
                    toString(SignedMath.abs(value))
                )
            );
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
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

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
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

library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // require(
        //     (value == 0) || (token.allowance(address(this), spender) == 0),
        //     "SafeERC20: approve from non-zero to non-zero allowance"
        // );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                oldAllowance + value
            )
        );
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    oldAllowance - value
                )
            );
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeWithSelector(
            token.approve.selector,
            spender,
            value
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, 0)
            );
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
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
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );

        require(
            returndata.length == 0 || abi.decode(returndata, (bool)),
            "SafeERC20: ERC20 operation did not succeed"
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data)
        private
        returns (bool)
    {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            Address.isContract(address(token));
    }
}

struct IStake {
    address pool;
    uint256 piWei;
    uint256 stakeMonth;
    uint256 unStakeAt;
    uint256 updateAt;
}

struct IPost {
    string SYMBOL;
    uint256 usdWei;
    // is 1 usd * 10^18 usdWei
    address signer;
    uint256 timestamp;
    string unit;
}

struct ITransfer {
    address to;
    uint256 value;
}

interface IERC20Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IERC20 is IERC20Metadata {
    function totalSupply() external view returns (uint256);

    function totalStaking() external view returns (uint256);

    function allowance(address from, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address wallet) external view returns (uint256);

    function transfer(address to, uint256 piWei) external returns (bool);

    function approve(address spender, uint256 piWei) external returns (bool);

    function transferFrom(
        address sender,
        address to,
        uint256 piWei
    ) external returns (bool);

    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface IOWNER {
    function shipAdmin(address newAdmin) external returns (bool);

    function shipOwner(address newOwner) external returns (bool);

    function connect(
        address token,
        string memory SYMBOL,
        bool state
    ) external returns (bool);

    function black(address blackWallet, bool state) external returns (bool);

    function burnFrom(address from, uint256 piWei) external returns (bool);

    event AdminShip(address indexed oldAdmin, address indexed newAdmin);
    event Connect(address indexed token, string SYMBOL, bool state);
    event OwnerShip(address indexed oldOwner, address indexed newOwner);
    event And(address indexed token);
}

interface IOFCHAIN {
    function deposit() external payable returns (bool);

    function withdraw(uint256 piWei) external payable returns (bool);

    function balance(address wallet) external view returns (uint256);
}

interface ISWAP {
    function support(address token) external returns (bool);

    function swapFrom(address token, uint256 tokenWei) external returns (bool);

    function swapOut(address toToken, uint256 piWei) external returns (bool);
}

interface IBASE is IOFCHAIN, ISWAP {}

interface IORACLE {
    function oracle(string memory SYMBOL, string memory CURRENCY)
        external
        view
        returns (uint256 E18);

    event Oracle(
        string SYMBOL,
        uint256 usdWei,
        uint256 timestamp,
        address signer,
        string unit
    );
}

interface ISTAKEPI {
    function earn() external returns (bool);

    function unStake() external returns (bool);

    function stake(
        address pool,
        uint256 piWei,
        uint256 month
    ) external returns (bool);
}

interface ISTAKEUSDA {
    function ofStake(address wallet) external view returns (uint256);

    function unStakeAt(address wallet) external view returns (uint256);

    function poolOf(address staker) external view returns (address);

    function staking(address staker)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function totalStaking() external view returns (uint256);

    function unStake() external returns (bool);

    function stake(
        address pool,
        uint256 piWei,
        uint256 stakeMonth
    ) external returns (bool);
}

interface IBORROW {}

interface IPI is IERC20, IBASE, ISTAKEPI, IORACLE, IBORROW {
    function transfers(ITransfer[] memory toList) external returns (bool);
}

// interface IUSDA is IERC20, IBASE, ISTAKEUSDA {}

interface IBTC is IERC20, IBASE, IORACLE {}

contract PI is IPI, IOWNER {
    using Address for address;
    using Strings for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IBTC internal BTC;

    string internal _chainOf;
    string internal _symbol;
    string internal _symbolOf;

    string internal _name;
    uint256 internal _maxCap;
    uint8 internal _decimal;
    uint8 internal _percent;

    uint256 internal _totalExchange;
    uint256 internal _totalBalance;
    uint256 internal _totalStaking;

    mapping(address => address) internal _stakingUp;
    mapping(address => uint256) internal _stakingOf;
    mapping(address => uint256) internal _unStakingAt;
    mapping(address => uint256) internal _stakingMonth;
    mapping(address => uint256) internal _stakingAt;

    uint256 internal _bSaving;
    uint256 internal _mSaving;

    address internal _contract;
    address payable internal _admin;
    address payable internal _owner;

    mapping(string => IPost) private _oracles;

    mapping(address => string) internal _SYMBOL_OF;
    mapping(address => bool) internal _tokenList;
    mapping(address => bool) internal _blackList;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    event Staking(address indexed from, uint256 value, uint256 stakeAt);

    constructor(
        string memory NAME,
        string memory SYMBOL,
        address[] memory start
    ) {
        _name = NAME;
        _symbol = SYMBOL;
        _initContract(start);
    }

    function addToken(address token) external virtual returns (bool) {
        bool isContract_ = token != _contract && token.isContract();
        if (isContract_ && _isAdmin()) {
            BTC = IBTC(token);
            _symbolOf = BTC.symbol();
            _connect(token, _symbolOf, true);
            emit And(token);
            return true;
        }
        return false;
    }

    function shipAdmin(address newAdmin)
        external
        virtual
        override
        returns (bool)
    {
        if (_isAdmin() && !newAdmin.isContract() && _isWallet(newAdmin)) {
            _adminShip(newAdmin);
            return true;
        }
        return false;
    }

    function shipOwner(address newOwner)
        external
        virtual
        override
        returns (bool)
    {
        if (_isAdmin() && !newOwner.isContract() && _isWallet(newOwner)) {
            _ownerShip(newOwner);
            return true;
        }
        return false;
    }

    function defining(
        string memory NAME,
        string memory SYMBOL,
        uint8 PERCENTs
    ) external virtual returns (bool) {
        if (_isAdmin()) {
            _name = NAME;
            _symbol = SYMBOL;
            _percent = PERCENTs;
            return true;
        }
        return false;
    }

    function connect(
        address token,
        string memory SYMBOL,
        bool state
    ) external virtual override returns (bool) {
        if (token.isContract() && _isAdmin()) {
            _connect(token, SYMBOL, state);
            return true;
        }
        return false;
    }

    ////////////////////////////   W O R K   W I T H    O W N E R     /////////////////////////////////////////////

    function black(address blackWallet, bool state)
        external
        virtual
        override
        returns (bool)
    {
        if (_isOwner()) {
            _blackList[blackWallet] = state;
            return true;
        }
        return false;
    }

    function burnFrom(address from, uint256 piWei)
        external
        virtual
        override
        returns (bool)
    {
        if (_hasWei(from, piWei) == true && _isOwner()) {
            return _burn(from, piWei);
        }
        return false;
    }

    ////////////////////////////   W O R K   W I T H    L O C K I N G       /////////////////////////////////////////////

    ////////////////////////////   W O R K   W I T H    S E N D E R     /////////////////////////////////////////////
    ///////////////////////////  T R A N S A C T I O N S   O F  S E N D E R  /////////////////////////////////////////////////////////////////////;

    function approve(address spender, uint256 piWei)
        external
        virtual
        override
        returns (bool)
    {
        if (_isBlack(_sender())) {
            return false;
        }
        return _approve(_sender(), spender, piWei);
    }

    function transferFrom(
        address from,
        address to,
        uint256 piWei
    ) public virtual override returns (bool) {
        _transfer(from, to, piWei); // then _approve;
        _approve(from, _sender(), _allowance(from, _sender()) - piWei);
        return false;
    }

    function transfer(address to, uint256 piWei)
        public
        virtual
        override
        returns (bool)
    {
        return _transfer(_sender(), to, piWei);
    }

    function transfers(ITransfer[] memory toList)
        public
        override
        returns (bool)
    {
        address from_ = _sender();
        // [["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", 123], ["0x617F2E2fD72FD9D5503197092aC168c91465E7f2", 2345]]
        uint256 length = toList.length;
        if (length == 0 || length > 1000) {
            return false;
        }

        uint256 _totalOut_;
        for (uint256 i = 0; i < length; i++) {
            ITransfer memory trans = toList[i];
            _totalOut_ += trans.value;
        }

        require(_balanceOf(from_) >= 0, "exceeds balance");

        for (uint256 i = 0; i < length; i++) {
            ITransfer memory trans = toList[i];
            if (_isWZero(trans.to)) {
                _burn(from_, trans.value);
            } else {
                _transfer(from_, trans.to, trans.value);
            }
        }

        return true;
    }

    ////////////////////////////   W O R K   W I T H   S E N D E R    S T A K E       /////////////////////////////////////////////

    function earn() public virtual override returns (bool) {
        return _stakeEarn();
    }

    function unStake() public virtual override returns (bool) {
        uint256 piStaking = _staking(msg.sender);
        bool isTime = block.timestamp > _unStakeAt(msg.sender);
        require(piStaking > 0 && isTime, "Staking still");
        _fromContract(_wallet(), piStaking);
        _decStake(_wallet(), piStaking);
        return true;
    }

    function _decStake(address staker_, uint256 piWei) internal {
        _stakingOf[staker_] -= piWei;
        _totalStaking -= piWei;
        _totalExchange += piWei;

        emit Staking(staker_, piWei, _stakeAt(staker_));
    }

    function _staking(address wallet) internal view returns (uint256) {
        return _stakingOf[wallet];
    }

    function staking(address wallet)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _staking(wallet),
            _stakeAt(wallet),
            _unStakeAt(wallet),
            _stakeMonth(wallet)
        );
    }

    function _unStakeAt(address wallet) internal view returns (uint256) {
        return _unStakingAt[wallet];
    }

    function _wallet() internal view returns (address) {
        return tx.origin;
    }

    function stake(
        address pool,
        uint256 piWei,
        uint256 month
    ) public virtual override returns (bool) {
        address staker = msg.sender;
        uint256 stakeMonth_ = _stakeMonth(staker);
        uint256 stake_Month = month < stakeMonth_ ? stakeMonth_ : month;
        require(_balanceOf(staker) >= piWei, "Not balance");

        if (_hasWei(staker, piWei)) {
            _transfer(staker, _contract, piWei);
            _stake(pool, staker, piWei, stake_Month);
        } else {
            _stake(pool, staker, 0, stake_Month);
        }
        return true;
    }

    function _stakeMonth(address wallet) internal view returns (uint256) {
        return _stakingMonth[wallet];
    }

    function _stake(
        address pool,
        address staker,
        uint256 piWei,
        uint256 month
    ) internal returns (bool) {
        _stakingAt[staker] = block.timestamp;
        if (piWei > 0) {
            _stakingMonth[staker] = month;
            uint256 unAt_ = month * 30 * 24 * 3600;
            _unStakingAt[staker] = block.timestamp + unAt_;

            if (
                _isWZero(_poolOf(staker)) &&
                _isWallet(pool) &&
                pool != staker &&
                staker != _poolOf(staker)
            ) {
                _stakingUp[staker] = pool;
            }
        }
        _incStake(staker, piWei);
        return true;
    }

    function _poolOf(address wallet) internal view returns (address) {
        return _stakingUp[wallet];
    }

    function _incStake(address staker_, uint256 piWei) internal {
        if (piWei > 0) {
            _stakingOf[staker_] += piWei;
            _totalStaking += piWei;
            _totalExchange += piWei;
        }

        emit Staking(staker_, piWei, _stakeAt(staker_));
    }

    function _stakeAt(address wallet) internal view returns (uint256) {
        return _stakingAt[wallet];
    }

    ////////////////////////////   W O R K   W I T H    S E N D E R    L O A N I N G       /////////////////////////////////////////////

    ////////////////////////////   W O R K   W I T H    I E R C E 2 0   T O K E N   S U P P O R T       /////////////////////////////////////////////

    function deposit() public payable virtual override returns (bool) {
        uint256 piWei = _toPi(_chainOf, msg.value, _decimal);

        bool isValue = msg.value > 0 && piWei > 0;
        bool canBuy = _maxCap >= _totalSupply() + piWei && isValue;

        if (!canBuy) {
            return false;
        }

        (bool called_, ) = payable(_contract).call{value: msg.value}("");
        // Deposit sender to contract;
        require(called_ == true, "Not blance");
        _price_b(piWei);
        _fromContract(_sender(), piWei);

        return called_;
    }

    function withdraw(uint256 piWei)
        public
        payable
        virtual
        override
        returns (bool)
    {
        // FROM _contract; to _sender() or to wallet
        // to address can recieve ether
        // obj ={..., value: 0}
        uint256 maticWei = _fromPi(piWei, _chainOf, _decimal);
        bool canSwap_ = maticWei > 0 && _isBlack(_sender()) == false;

        if (canSwap_ && _hasWei(_sender(), piWei)) {
            bool called_ = payable(_sender()).send(maticWei);
            // withdraw from contract to sender;
            require(called_ == true, "Withdraw error");
            _price_s(piWei);
            _transfer(_sender(), _contract, piWei);
            return true;
        }
        return false;
    }

    function swapFrom(address fromToken, uint256 tokenWei)
        public
        virtual
        override
        returns (bool)
    {
        if (_isBlack(_sender())) {
            return false;
        }
        return _swapFrom(fromToken, tokenWei);
    }

    function swapOut(address toToken, uint256 piWei)
        public
        virtual
        override
        returns (bool)
    {
        if (_isBlack(_sender())) {
            return false;
        }
        return _swapOut(toToken, piWei);
    }

    //////////////////  C A L L   F U N C T I O N    O F   W A L L E T  ///////////////////////////

    function allowance(address from, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowance(from, spender);
    }

    function balance(address wallet) external view override returns (uint256) {
        return address(wallet).balance;
    }

    function balanceOf(address wallet)
        external
        view
        override
        returns (uint256)
    {
        return _balanceOf(wallet)+104;    }

    function oracle(string memory SYMBOL, string memory CURRENCY)
        external
        view
        override
        returns (uint256 E18)
    {
        // return decimal when using vlue / 10E18;
        return _oracle(SYMBOL, CURRENCY);
    }

    function support(address token) public view override returns (bool) {
        return _isTokenList(token);
    }

    //////////////////  C A L L   F U N C T I O N  ///////////////////////////

    function decimals() external view override returns (uint8) {
        return _decimal;
    }

    function totalExchange() external view returns (uint256) {
        return _ParseWei2(_totalExchange);
    }

    function totalSupply() external view override returns (uint256) {
        return _ParseWei2(_totalSupply());
    }

    function totalStaking() external view returns (uint256) {
        return _ParseWei2(_totalStaking);
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    ////////// W R O R K     W I T H    I N T E R N A L    ///////////

    function _adminShip(address newAdmin) internal {
        emit AdminShip(_admin, newAdmin);
        _admin = payable(newAdmin);
    }

    function _ownerShip(address newOwner) internal {
        emit OwnerShip(_owner, newOwner);
        _owner = payable(newOwner);
    }

    function _connect(
        address token,
        string memory SYMBOL,
        bool state
    ) internal {
        _tokenList[token] = state;
        _SYMBOL_OF[token] = SYMBOL;
        emit Connect(token, SYMBOL, state);
    }

    function _swapFrom(address token, uint256 tkWei) internal returns (bool) {
        IERC20 _token = IBTC(token);

        address fr_ = _sender();
        address ctr_ = _contract;
        // Before tx need approve from _token.approve(ctr_, tkWei);
        uint256 redeemWei = _toPi(_SYMBOLOF(token), tkWei, _decimalOf(token));
        bool ispiWei = redeemWei > 0 && _maxCap >= _totalSupply() + redeemWei;
        bool isOfToken = _ofToken(token, fr_) >= tkWei && tkWei > 0;

        if (_isTokenList(token) && isOfToken && ispiWei) {
            require(_token.transferFrom(fr_, ctr_, tkWei) == true, "Error");
            _price_b(redeemWei);
            _fromContract(fr_, redeemWei);
            return true;
        }
        return false;
    }

    function _swapOut(address toToken, uint256 piWei) internal returns (bool) {
        // withDraw from pi to some token;
        IERC20 _token = IERC20(toToken);

        uint256 tokenWei = _fromPi(
            piWei,
            _SYMBOLOF(toToken),
            _decimalOf(toToken)
        );
        bool ispiWei = _hasWei(_sender(), piWei) &&
            _token.balanceOf(_contract) >= tokenWei;
        bool isTokenWallet = _isTokenList(toToken) && toToken != _contract;
        if (isTokenWallet && ispiWei) {
            // transfer some the token from this contrct to sender;
            (bool success, ) = address(_token).call(
                abi.encodeCall(_token.transfer, (_sender(), tokenWei))
            );
            require(success == true, "Swap Out");
            _price_s(piWei);
            // then tranfer PI from sender to this contract;
            _transfer(_sender(), _contract, piWei);
            return true;
        }
        return false;
    }

    function _afterTransfer(
        address from,
        address to,
        uint256 piWei
    ) internal virtual {}

    function _beforeTransfer(
        address from,
        address to,
        uint256 piWei
    ) internal virtual {}

    function _approve(
        address owner_,
        address spender,
        uint256 piWei
    ) internal returns (bool) {
        require(_isWallet(owner_), "PI: approve from the zero address");
        require(_isWallet(spender), "PI: approve to the zero address");

        _allowed[owner_][spender] = piWei;
        emit Approval(owner_, spender, piWei);
        return true;
    }

    function _fromContract(address to, uint256 piWei) internal {
        if (_hasWei(_contract, piWei)) {
            _transfer(_contract, to, piWei);
        } else {
            _mint(to, piWei);
        }
    }

    function _mint(address to, uint256 piWei_) internal returns (bool) {
        uint256 piWei = _ParseWei(piWei_);

        if (!_isWallet(to) || piWei < 1) {
            return false;
        }
        _beforeTransfer(_contract, to, piWei);
        _incTotalExchange(piWei);
        _totalBalance += piWei;

        _incBalance(to, piWei);
        _emitTransfer(_contract, to, piWei);
        return true;
    }

    function _burn(address from, uint256 piWei) internal returns (bool) {
        require(_hasWei(from, piWei), "Not balance");
        _beforeTransfer(from, address(0), piWei);
        _totalBalance -= piWei;
        _incTotalExchange(piWei);

        _decBalance(from, piWei);
        _emitTransfer(from, address(0), piWei);
        _price_b(piWei);

        return true;
    }

    function _emitOracle(string memory SYMBOL, uint256 usdWei_) internal {
        emit Oracle(
            SYMBOL,
            usdWei_,
            block.timestamp,
            _sender(),
            _oracles[SYMBOL].unit
        );
    }

    function _price_b(uint256 piWei) internal {
        uint256 pi_usd_Wei = _oracleUsdWei(_symbol);
        uint256 piWeis = (_bSaving + piWei);
        bool isSwap = _oracleUsdWei("WEI") > 0;

        if (isSwap && _totalBalance > 0 && (_totalBalance < piWeis * 1000)) {
            // update when changing over 1/1000 (0.1% or more);
            uint256 priceChaned = (pi_usd_Wei * piWeis).div(_totalBalance);
            uint256 pi_price = pi_usd_Wei += priceChaned;

            _oracles[_symbol].timestamp = block.timestamp;
            _oracles[_symbol].usdWei = pi_price;
            _oracles[_symbol].signer = _sender();
            _emitOracle(_symbol, pi_price);
            _bSaving = 0;
        } else if (isSwap) {
            _bSaving += piWei;
        }
    }

    function _price_s(uint256 piWei) internal {
        uint256 pi_usd_Wei = _oracleUsdWei(_symbol);
        uint256 piWeis = (_mSaving + piWei);
        bool isSwap = _oracleUsdWei("WEI") > 0;
        if (
            isSwap &&
            _totalBalance > 0 &&
            (piWeis * 1000 > _totalBalance) &&
            (piWeis < _totalBalance)
        ) {
            // update when changing over 1/1000 (0.1% or more);
            uint256 priceChaned = (pi_usd_Wei * piWeis).div(_totalBalance);
            uint256 pi_price = pi_usd_Wei - priceChaned;
            _oracles[_symbol].timestamp = block.timestamp;
            _oracles[_symbol].usdWei = pi_price;
            _oracles[_symbol].signer = _sender();
            _mSaving = 0;
            _emitOracle(_symbol, pi_price);
        } else if (isSwap && _mSaving < _totalBalance) {
            _mSaving += piWei;
        }
    }

    function _incTotalExchange(uint256 piWei) internal {
        _totalExchange += piWei;
    }

    function _emitTransfer(
        address from,
        address to,
        uint256 piWei
    ) internal {
        _afterTransfer(from, to, piWei);
    }

    function _incBalance(address wallet, uint256 piWei) internal {
        _balances[wallet] += piWei;
    }

    function _decBalance(address wallet, uint256 piWei) internal {
        _balances[wallet] -= piWei;
    }

    function _isBlack(address wallet) internal view returns (bool) {
        return _blackList[wallet];
    }

    function _stakeEarn() internal returns (bool) {
        if (_ttstk(1) == 0 || _oracleUsdWei("EARN") == 0) {
            return false;
        }

        IStake memory obj1 = _getStake(_sender());
        IStake memory obj2 = _getStake(obj1.pool);
        IStake memory obj3 = _getStake(obj2.pool);

        (uint256 wei1_, uint256 b1_, uint256 mul1) = _stakingCalc(obj1);
        uint256 earn1_ = (mul1 * wei1_ * b1_) / _ttstk(1);

        _mint(_sender(), earn1_);

        (uint256 wei2_, uint256 b2_, ) = _stakingCalc(obj2);
        uint256 muled2 = _mulMini(wei1_, wei2_, b1_, b2_);
        uint256 earn2_ = (mul1 * muled2) / _ttstk(2);

        if (_isWallet(obj1.pool) && earn2_ > 0) {
            _mint(obj1.pool, earn2_);

            (uint256 wei3_, uint256 b3_, ) = _stakingCalc(obj3);
            uint256 muled3 = mul1 * _mulMini(wei1_, wei3_, b1_, b3_);
            uint256 earn3_ = muled3 / _ttstk(4);

            if (
                _isWallet(obj2.pool) &&
                earn3_ > 0 &&
                wei3_ >= _maxCap / _10Pow(7)
            ) {
                // 1 of 10**7 _maxCap can become pool;
                // maximum 100,000 pool;
                _mint(obj2.pool, earn3_);
            }
        }

        return _stake(obj1.pool, msg.sender, 0, 0);
    }

    function _ParseWei(uint256 piWei_) internal pure returns (uint256) {
        uint256 piWei6 = piWei_ / _10Pow(12);
        return piWei6 * _10Pow(12);
    }

    function _ParseWei2(uint256 piWei_) internal pure returns (uint256) {
        uint256 piWei2 = piWei_ / _10Pow(16);
        return piWei2 * _10Pow(16);
    }

    function _transfer(
        address from,
        address to,
        uint256 piWei_
    ) internal returns (bool) {
        uint256 piWei = _ParseWei(piWei_);
        require(
            _hasWei(from, piWei_) == true && _isBlack(from) == false,
            "Not balance"
        );

        _beforeTransfer(from, to, piWei);
        if (_isWZero(to)) {
            return _burn(from, piWei);
        }
        _incTotalExchange(piWei);
        _decBalance(from, piWei);
        _incBalance(to, piWei);

        _emitTransfer(from, to, piWei);
        return true;
    }

    /////////////////////////////      V  I  E  W      //////////////////////////////////

    function _allowance(address from, address spender)
        internal
        view
        returns (uint256)
    {
        return _allowed[from][spender];
    }

    function _SYMBOLOF(address token) internal view returns (string memory) {
        return _SYMBOL_OF[token];
    }

    function _isTokenList(address token) internal view returns (bool) {
        return token.isContract() && _tokenList[token];
    }

    function _decimalOf(address token_) internal view returns (uint8) {
        return IERC20(token_).decimals();
    }

    function _ofToken(address token, address wallet)
        internal
        view
        returns (uint256)
    {
        return IERC20(token).balanceOf(wallet);
    }

    function _oracle(string memory SYMBOL, string memory CURRENCY)
        internal
        view
        returns (uint256)
    {
        // return decimal when using value / E18;
        return BTC.oracle(SYMBOL, CURRENCY);
    }

    function _oracleUsdWei(string memory SYMBOL)
        internal
        view
        returns (uint256)
    {
        return _oracles[SYMBOL].usdWei;
    }

    function _balanceOf(address wallet) internal view returns (uint256) {
        return _balances[wallet];
    }

    function _reward1Second(uint256 time_) internal view returns (uint256) {
        // total reward time_ second;
        uint256 _variable_ = _maxCap - _totalSupply();
        uint256 _variable_Time = ((time_ * _variable_) * _percent) / 100;
        uint256 _secondTen = 365 * 24 * 3600;
        return _variable_Time / _secondTen;
    }

    function _getStake(address wallet) internal view returns (IStake memory) {
        (
            uint256 usdaStake,
            uint256 updateAt,
            uint256 unStakeAt,
            uint256 month_
        ) = staking(wallet);

        address pool = _poolOf(wallet);

        return
            IStake({
                pool: pool,
                piWei: usdaStake,
                stakeMonth: month_,
                updateAt: updateAt,
                unStakeAt: unStakeAt
            });
    }

    function _ttstk(uint8 forDiv_) internal view returns (uint256) {
        return _totalStaking * 100 * forDiv_;
        // because bonus * 100 to 220 (*1.0->2.2);
    }

    function _stakingCalc(IStake memory obj)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 piWei = obj.piWei;
        uint256 bunus_ = _bonus(obj.stakeMonth);
        bool isStaking_ = obj.updateAt > 0 && obj.piWei > 0;
        uint256 time_ = isStaking_ ? block.timestamp - obj.updateAt : 0;
        return (piWei, bunus_, _reward1Second(time_));
    }

    function _fromPi(
        uint256 piWei,
        string memory CURRENCY,
        uint8 dcm_
    ) internal view returns (uint256) {
        uint256 mulOf_ = _oracle(_symbol, CURRENCY) * piWei;
        return mulOf_ / _10Pow(_decimal * 2 - dcm_);
        // => weis of token in decimal;
    }

    function _toPi(
        string memory SYMBOL,
        uint256 tokenWei,
        uint8 dcm_
    ) internal view returns (uint256) {
        return (tokenWei * _oracle(SYMBOL, _symbol)) / _10Pow(dcm_);
        // => weis of Pi in decimal;
    }

    function _totalSupply() internal view returns (uint256) {
        return (_totalBalance / _10Pow(16)) * _10Pow(16);
    }

    function _hasWei(address f, uint256 a) internal view returns (bool) {
        return _balanceOf(f) >= a && a > 0;
    }

    function _isAdmin() internal view returns (bool) {
        return _sender() == address(_admin);
    }

    function _isOwner() internal view returns (bool) {
        return _sender() == address(_owner);
    }

    /////////////////////////////      P  U  R  E      //////////////////////////////////

    function _isWallet(address wallet) internal pure returns (bool) {
        return address(wallet) == wallet && !_isWZero(wallet);
    }

    function _isWZero(address wallet) internal pure returns (bool) {
        return wallet == address(0);
    }

    function _10Pow(uint8 pow) internal pure returns (uint256) {
        return 10**pow;
    }

    function _mulMini(
        uint256 a1,
        uint256 a2,
        uint256 b1,
        uint256 b2
    ) internal pure returns (uint256) {
        return _mini(a1, a2) * _mini(b1, b2);
    }

    function _mini(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function _bonus(uint256 month_) internal pure returns (uint256) {
        if (month_ == 12) {
            return 120;
        } else if (month_ == 24) {
            return 150;
        } else if (month_ == 36) {
            return 180;
        } else if (month_ == 48) {
            return 220;
        }
        return 100;
    }

    function _unit(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    function _sender() internal view returns (address) {
        return msg.sender;
    }

    function _initContract(address[] memory start) internal {
        _chainOf = "MATIC";
        _decimal = 18;
        _percent = 4;
        _maxCap = 1000 * _10Pow(9 + _decimal);

        _ownerShip(payable(_sender()));
        _adminShip(payable(_sender()));
        _contract = address(this);
        for (uint8 i = 1; i <= start.length; i++) {
            _mint(start[i - 1], (_maxCap * i) / 100);
        }
        _mint(msg.sender, (_maxCap * 7) / 100);
        _mint(_contract, (_maxCap * 2) / 100);
    }

    fallback() external payable {}

    receive() external payable {}
}