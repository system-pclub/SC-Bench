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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: turkeys/turkeyRace.sol


pragma solidity ^0.8.17;




// Interface for the turkeysGameContract
interface ITurkeysGameContract {
    function stats(uint256 tokenId) external view returns (uint8 strength, uint8 intelligence, uint8 speed, uint8 bravery);
}

contract TurkeyRace is Ownable {

    struct Racer {
        uint256 tokenId;
        uint256 endTime;
    }

    struct Bet {
        uint256 amount;
        address bettor;
    }

    uint256 public eligibleFee = 400000000000;

    mapping(uint256 => Racer) public eligibleRacers;
    mapping(uint256 => Racer) public currentRacers;
    mapping(uint256 => Bet[]) public bets;
    address public nftAddress = 0x49C59D51a3e0fA9df6c80F38Dda32b66E51b21c8;
    address public paymentToken = 0xA8b28269376a854Ce52B7238733cb257Dd3934e8;
    address public rewardWallet = 0xA1E18278f32c8Fc411Fd15C1dFD760976c5b48Ef;

    IERC20 public paymentTokenContract = IERC20(0xA8b28269376a854Ce52B7238733cb257Dd3934e8);
    ITurkeysGameContract public turkeysGameContract = ITurkeysGameContract(0x49C59D51a3e0fA9df6c80F38Dda32b66E51b21c8);

    uint256[] public currentRacerIds;

    event PreRace(uint256[] racerIds);
    event RaceResult(uint256 winnerId);
    event NewBet(uint256 tokenId, uint256 amount);
    event Overtake(uint256 overtaker, uint256 overtaken);
    event TurkeyPun(string message);
    event EligibilityChanged(uint256 tokenId, bool eligible);

    function makeEligible(uint256[] memory tokenIds) public {
        IERC721 nft = IERC721(nftAddress);
        IERC20 token = IERC20(paymentToken);

        uint256 totalFee = eligibleFee * tokenIds.length;
        
        require(token.transferFrom(msg.sender, address(this), totalFee), "Fee payment failed");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "You don't own this NFT");
            eligibleRacers[tokenId] = Racer(tokenId, block.timestamp + 7 days);
            emit EligibilityChanged(tokenId, true);
        }
    }

    function preRace() public onlyOwner {
        uint256 eligibleCount = 0;

        // Count the number of eligible racers
        for (uint256 i = 1; i <= 444; i++) { // replace 1000 with a variable or function that gets the actual max tokenId
            if (eligibleRacers[i].endTime >= block.timestamp) {
                eligibleCount++;
            }
        }

        require(eligibleCount >= 5, "Not enough eligible racers");

        uint256[] memory racerIds = new uint256[](5);
        for (uint256 i = 0; i < 5; ) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, i))) % 1000 + 1; // replace 1000 with actual max tokenId

            if (eligibleRacers[random].endTime >= block.timestamp) {
                currentRacerIds.push(random);
                racerIds[i] = random;
                currentRacers[random] = eligibleRacers[random];
                i++;
            }
        }

        emit PreRace(racerIds);
    }

    function placeBet(uint256 tokenId, uint256 amount) public {
        require(currentRacers[tokenId].tokenId != 0, "This NFT is not racing");

        IERC20 token = IERC20(paymentToken);
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        bets[tokenId].push(Bet(amount, msg.sender));
        emit NewBet(tokenId, amount);
    }

    function race() public onlyOwner {
        uint256 winnerId;
    
        uint8[] memory speedStats = new uint8[](currentRacerIds.length);
        uint256 maxScore = 0;

        for (uint256 i = 0; i < currentRacerIds.length; i++) {
            (,,speedStats[i],) = turkeysGameContract.stats(currentRacerIds[i]);
            
            uint256 adjustedSpeed = uint256(sqrt(speedStats[i]));  // Use square root to adjust speed
            uint256 randomFactor = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % 100;
            
            uint256 combinedValue = adjustedSpeed + randomFactor;
            
            if (combinedValue > maxScore) {
                maxScore = combinedValue;
                winnerId = currentRacerIds[i];
            }
        }

        // Placeholder array to track current positions
        uint256[] memory positions = new uint256[](currentRacerIds.length);
        
        // Random overtakes and turkey puns
        for(uint i = 0; i < 6; i++) {
            uint256 randomEvent = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % 10;
            
            if (randomEvent < 3) { // 30% chance of an overtake event
                uint256 overtakerIndex = uint256(keccak256(abi.encodePacked(block.timestamp, i, "overtaker"))) % currentRacerIds.length;
                uint256 overtakenIndex = uint256(keccak256(abi.encodePacked(block.timestamp, i, "overtaken"))) % currentRacerIds.length;

                // Simple logic to make sure a faster NFT overtakes a slower one
                if (speedStats[currentRacerIds[overtakerIndex]] > speedStats[currentRacerIds[overtakenIndex]]) {
                    // Swap positions
                    uint256 temp = positions[overtakerIndex];
                    positions[overtakerIndex] = positions[overtakenIndex];
                    positions[overtakenIndex] = temp;
                    
                    emit Overtake(currentRacerIds[overtakerIndex], currentRacerIds[overtakenIndex]);
                }
            } else { // 70% chance of a turkey pun event
                uint256 punIndex = uint256(keccak256(abi.encodePacked(block.timestamp, i, "pun"))) % 5;
                
                if (punIndex == 0) {
                    emit TurkeyPun("This turkey is really winging it!");
                } else if (punIndex == 1) {
                    emit TurkeyPun("What a peck-tacular performance!");
                } else if (punIndex == 2) {
                    emit TurkeyPun("Gobble up the competition!");
                } else if (punIndex == 3) {
                    emit TurkeyPun("Feather or not he wins, it's been a great race!");
                } else if (punIndex == 4) {
                    emit TurkeyPun("This turkey is really strutting its stuff!");
                }
            }
        }

        // Distribute rewards
        IERC20 token = IERC20(paymentToken);
        uint256 totalBet = 0;

        // Compute total bet amount on the winner
        for (uint256 i = 0; i < bets[winnerId].length; i++) {
            totalBet += bets[winnerId][i].amount;
        }

        // Transfer 5% to the NFT owner, 10% to the specified wallet
        IERC721 nft = IERC721(nftAddress);
        uint256 reward = (totalBet * 5) / 100;
        require(token.transfer(nft.ownerOf(winnerId), reward), "Transfer failed");
        require(token.transfer(rewardWallet, (totalBet * 10) / 100), "Transfer failed");

        // Split 85% between bettors
        for (uint256 i = 0; i < bets[winnerId].length; i++) {
            uint256 bettorReward = ((totalBet * 85) / 100 * bets[winnerId][i].amount) / totalBet;
            require(token.transfer(bets[winnerId][i].bettor, bettorReward), "Transfer failed");
        }

        // Reset current racers
        for (uint256 i = 0; i < currentRacerIds.length; i++) {
            delete currentRacers[currentRacerIds[i]];
        }
        // Clear the IDs as well
        delete currentRacerIds;

        updateAllEligibilities();

        emit RaceResult(winnerId);
    }

    function sqrt(uint x) public pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function updateAllEligibilities() public {
        for (uint256 i = 0; i < currentRacerIds.length; i++) {
            uint256 tokenId = currentRacerIds[i];
            
            if (eligibleRacers[tokenId].endTime != 0) {
                // Check if the eligibility has expired
                if (block.timestamp > eligibleRacers[tokenId].endTime) {
                    delete eligibleRacers[tokenId];
                    emit EligibilityChanged(tokenId, false);
                }
            }
        }
    }

    function setFee(uint256 newFee) public onlyOwner {
        eligibleFee = newFee;
    }

    function withdrawStuckEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    function withdrawStuckTokens(uint256 amount) external onlyOwner {
        require(paymentTokenContract.balanceOf(address(this)) >= amount, "Insufficient token balance");
        paymentTokenContract.transfer(owner(), amount);
    }

    function getCurrentRacerIds() public view returns (uint256[] memory) {
        return currentRacerIds;
    }

    function updateNftAddress(address _newNftAddress) external onlyOwner {
        nftAddress = _newNftAddress;
    }

    function updatePaymentToken(address _newPaymentToken) external onlyOwner {
        paymentToken = _newPaymentToken;
    }

    function updateRewardWallet(address _newRewardWallet) external onlyOwner {
        rewardWallet = _newRewardWallet;
    }
}