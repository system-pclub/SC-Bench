//SPDX-License-Identifier: MIT

/**                                       
                   %%(((       #%(                                               
                    %%%(((((   #%%((    %((     %                                
                     ((%(((((((//(%(((((/#%(((//((                               
                       (((((((((((((//(((//((/((((/////                          
                         (((/(((((*(((/////*((//////////                         
                          ,.////////.../////./////./(%(/                         
                          %%%%%%%%%%%%&&&&&&&%%%%%%%%%%%                         
                     &&&((%%%%(&@@@@((&&&&&&&(&@@@@((%%%(((&&                    
                     %%(%(%%%(@@@@@@@@(%%%%%(@@@@@@@@(%%((%(%                    
                       %,,%%%,@@@@@@@@,%%%%%,@@@@@@@@,%%*,,%                     
                        (,%%%((*,,,,/((%%%%%((*,,,,/((%%*,(                      
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                             ((((%%(&@,@,,,,@,/(%%((((                           
                              %%%%%,,,./////*,,,%%%%%                            
                              %%%%%%%%%%%%%///%%%%%%%                            
                                       ,,,,,                                     
                                       (((((                                     
                               (####../,%%%,/*#####                              
                             /#####////.///./////####/                           
                          ///////.///////////////.//////                         
                         ((( ,///./////////////// ///*,(                         
                        %(     ,,///////////////       (%%                       
                       %%        //.//////////          #%%                      
                    %%%%         ,/,..///,,/,*            %%%                    
                  &&&&&%         (((((,/,**(((            %&&&&&                 
                %%(%%*,%%      ////((((*(((((####       #%%,%%%(%                
                %%(%%   %         ( ##     ( (          #%  %%%(%                
                   ,%%%          %((       ((%             %%*,                  
                             %%((*%         %*((%%                               
                            @@@//((         ((//@@@                              
                          &@@@@@@@@@       @@@@@@@@@@                     

°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
                Website: https://rekt.kids/
                Twitter: https://twitter.com/RektKidsOnEth
                Telegram: https://t.me/RektBeyondRecoveryPortal
°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
**/

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC721A {
    error ApprovalCallerNotOwnerNorApproved();
    error ApprovalQueryForNonexistentToken();
    error BalanceQueryForZeroAddress();
    error BalanceMustBeBelowMaxWallet();
    error MintToZeroAddress();
    error MintZeroQuantity();
    error OwnerQueryForNonexistentToken();
    error TransferCallerNotOwnerNorApproved();
    error TransferFromIncorrectOwner();
    error TransferToNonERC721ReceiverImplementer();
    error TransferToZeroAddress();
    error URIQueryForNonexistentToken();
    error MintERC2309QuantityExceedsLimit();
    error OwnershipNotInitializedForExtraData();
    error InvalidQueryRange();

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
        uint24 extraData;
    }

    function totalSupply() external view returns (uint256);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function explicitOwnershipOf(uint256 tokenId) external view returns (TokenOwnership memory);
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external payable;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;
    function approve(address to, uint256 tokenId) external payable;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721A is IERC721A {
    struct TokenApprovalRef {
        address value;
    }

    uint256 private constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;
    uint256 private constant _BITPOS_NUMBER_MINTED = 64;
    uint256 private constant _BITPOS_NUMBER_BURNED = 128;
    uint256 private constant _BITPOS_AUX = 192;
    uint256 private constant _BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;
    uint256 private constant _BITMASK_BURNED = 1 << 224;
    uint256 private constant _BITPOS_NEXT_INITIALIZED = 225;
    uint256 private constant _BITMASK_NEXT_INITIALIZED = 1 << 225;
    uint256 private constant _BITPOS_EXTRA_DATA = 232;
    uint256 private constant _BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;
    uint256 private constant _MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;


    bytes32 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;


    uint256 private _currentIndex;
    uint256 private _burnCounter;
    string private _name;
    string private _symbol;

    mapping(uint256 => uint256) private _packedOwnerships;
    mapping(address => uint256) private _packedAddressData;
    mapping(uint256 => TokenApprovalRef) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

    function totalSupply() public view virtual override returns (uint256) {
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view virtual returns (uint256) {
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) _revert(BalanceQueryForZeroAddress.selector);
        return _packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _numberMinted(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> _BITPOS_NUMBER_MINTED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _numberBurned(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> _BITPOS_NUMBER_BURNED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    function _getAux(address owner) internal view returns (uint64) {
        return uint64(_packedAddressData[owner] >> _BITPOS_AUX);
    }

    function _setAux(address owner, uint64 aux) internal virtual {
        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
        assembly {
            auxCasted := aux
        }
        packed = (packed & _BITMASK_AUX_COMPLEMENT) | (auxCasted << _BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == 0x01ffc9a7 ||
            interfaceId == 0x80ac58cd ||
            interfaceId == 0x5b5e139f;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    function explicitOwnershipOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (TokenOwnership memory ownership)
    {
        unchecked {
            if (tokenId >= _startTokenId()) {
                if (tokenId < _nextTokenId()) {
                    while (!_ownershipIsInitialized(tokenId)) --tokenId;
                    return _ownershipAt(tokenId);
                }
            }
        }
    }

    function _tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) private view returns (uint256[] memory) {
        unchecked {
            if (start >= stop) _revert(InvalidQueryRange.selector);
            if (start < _startTokenId()) {
                start = _startTokenId();
            }
            uint256 stopLimit = _nextTokenId();
            if (stop >= stopLimit) {
                stop = stopLimit;
            }
            uint256[] memory tokenIds;
            uint256 tokenIdsMaxLength = balanceOf(owner);
            bool startLtStop = start < stop;
            assembly {
                tokenIdsMaxLength := mul(tokenIdsMaxLength, startLtStop)
            }
            if (tokenIdsMaxLength != 0) {
                if (stop - start <= tokenIdsMaxLength) {
                    tokenIdsMaxLength = stop - start;
                }
                assembly {
                    tokenIds := mload(0x40)
                    mstore(0x40, add(tokenIds, shl(5, add(tokenIdsMaxLength, 1))))
                }
                TokenOwnership memory ownership = explicitOwnershipOf(start);
                address currOwnershipAddr;
                if (!ownership.burned) {
                    currOwnershipAddr = ownership.addr;
                }
                uint256 tokenIdsIdx;
                do {
                    ownership = _ownershipAt(start);
                    assembly {
                        switch mload(add(ownership, 0x40))
                        case 0 {
                            if mload(ownership) {
                                currOwnershipAddr := mload(ownership)
                            }
                            if iszero(shl(96, xor(currOwnershipAddr, owner))) {
                                tokenIdsIdx := add(tokenIdsIdx, 1)
                                mstore(add(tokenIds, shl(5, tokenIdsIdx)), start)
                            }
                        }
                        default {
                            currOwnershipAddr := 0
                        }
                        start := add(start, 1)
                    }
                } while (!(start == stop || tokenIdsIdx == tokenIdsMaxLength));
                assembly {
                    mstore(tokenIds, tokenIdsIdx)
                }
            }
            return tokenIds;
        }
    }

    function tokensOfOwner(address owner) external view virtual override returns (uint256[] memory) {
        uint256 start = _startTokenId();
        uint256 stop = _nextTokenId();
        uint256[] memory tokenIds;
        if (start != stop) tokenIds = _tokensOfOwnerIn(owner, start, stop);
        return tokenIds;
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    function _ownershipOf(uint256 tokenId) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    function _ownershipAt(uint256 index) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnerships[index]);
    }

    function _ownershipIsInitialized(uint256 index) internal view virtual returns (bool) {
        return _packedOwnerships[index] != 0;
    }

    function _initializeOwnershipAt(uint256 index) internal virtual {
        if (_packedOwnerships[index] == 0) {
            _packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256 packed) {
        if (_startTokenId() <= tokenId) {
            packed = _packedOwnerships[tokenId];
            if (packed == 0) {
                if (tokenId >= _currentIndex) _revert(OwnerQueryForNonexistentToken.selector);
                for (;;) {
                    unchecked {
                        packed = _packedOwnerships[--tokenId];
                    }
                    if (packed == 0) continue;
                    if (packed & _BITMASK_BURNED == 0) return packed;
                    _revert(OwnerQueryForNonexistentToken.selector);
                }
            }
            if (packed & _BITMASK_BURNED == 0) return packed;
        }
        _revert(OwnerQueryForNonexistentToken.selector);
    }

    function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {
        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> _BITPOS_START_TIMESTAMP);
        ownership.burned = packed & _BITMASK_BURNED != 0;
        ownership.extraData = uint24(packed >> _BITPOS_EXTRA_DATA);
    }

    function _packOwnershipData(address owner, uint256 flags) private view returns (uint256 result) {
        assembly {
            owner := and(owner, _BITMASK_ADDRESS)
            result := or(owner, or(shl(_BITPOS_START_TIMESTAMP, timestamp()), flags))
        }
    }

    function _nextInitializedFlag(uint256 quantity) private pure returns (uint256 result) {
        assembly {
            result := shl(_BITPOS_NEXT_INITIALIZED, eq(quantity, 1))
        }
    }

    function approve(address to, uint256 tokenId) public payable virtual override {
        _approve(to, tokenId, true);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        if (!_exists(tokenId)) _revert(ApprovalQueryForNonexistentToken.selector);

        return _tokenApprovals[tokenId].value;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool result) {
        if (_startTokenId() <= tokenId) {
            if (tokenId < _currentIndex) {
                uint256 packed;
                while ((packed = _packedOwnerships[tokenId]) == 0) --tokenId;
                result = packed & _BITMASK_BURNED == 0;
            }
        }
    }

    function _isSenderApprovedOrOwner(
        address approvedAddress,
        address owner,
        address msgSender
    ) private pure returns (bool result) {
        assembly {
            owner := and(owner, _BITMASK_ADDRESS)
            msgSender := and(msgSender, _BITMASK_ADDRESS)
            result := or(eq(msgSender, owner), eq(msgSender, approvedAddress))
        }
    }

    function _getApprovedSlotAndAddress(uint256 tokenId)
        private
        view
        returns (uint256 approvedAddressSlot, address approvedAddress)
    {
        TokenApprovalRef storage tokenApproval = _tokenApprovals[tokenId];
        assembly {
            approvedAddressSlot := tokenApproval.slot
            approvedAddress := sload(approvedAddressSlot)
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        from = address(uint160(uint256(uint160(from)) & _BITMASK_ADDRESS));

        if (address(uint160(prevOwnershipPacked)) != from) _revert(TransferFromIncorrectOwner.selector);

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
            if (!isApprovedForAll(from, _msgSenderERC721A())) _revert(TransferCallerNotOwnerNorApproved.selector);

        _beforeTokenTransfers(from, to, tokenId, 1);

        assembly {
            if approvedAddress {
                sstore(approvedAddressSlot, 0)
            }
        }

        unchecked {
            --_packedAddressData[from];
            ++_packedAddressData[to];

            _packedOwnerships[tokenId] = _packOwnershipData(
                to,
                _BITMASK_NEXT_INITIALIZED | _nextExtraData(from, to, prevOwnershipPacked)
            );

            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (_packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != _currentIndex) {
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;
        assembly {
            log4(
                0,
                0,
                _TRANSFER_EVENT_SIGNATURE,
                from,
                toMasked,
                tokenId
            )
        }
        if (toMasked == 0) _revert(TransferToZeroAddress.selector);

        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual override {
        transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            }
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try ERC721A__IERC721Receiver(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns (
            bytes4 retval
        ) {
            return retval == ERC721A__IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            }
            assembly {
                revert(add(32, reason), mload(reason))
            }
        }
    }

    function _mint(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (quantity == 0) _revert(MintZeroQuantity.selector);

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;

            if (toMasked == 0) _revert(MintToZeroAddress.selector);

            uint256 end = startTokenId + quantity;
            uint256 tokenId = startTokenId;

            do {
                assembly {
                    log4(
                        0, 
                        0,
                        _TRANSFER_EVENT_SIGNATURE,
                        0,
                        toMasked,
                        tokenId 
                    )
                }
            } while (++tokenId != end);

            _currentIndex = end;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _mintERC2309(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) _revert(MintToZeroAddress.selector);
        if (quantity == 0) _revert(MintZeroQuantity.selector);
        if (quantity > _MAX_MINT_ERC2309_QUANTITY_LIMIT) _revert(MintERC2309QuantityExceedsLimit.selector);

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            emit ConsecutiveTransfer(startTokenId, startTokenId + quantity - 1, address(0), to);

            _currentIndex = startTokenId + quantity;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {
        _mint(to, quantity);

        unchecked {
            if (to.code.length != 0) {
                uint256 end = _currentIndex;
                uint256 index = end - quantity;
                do {
                    if (!_checkContractOnERC721Received(address(0), to, index++, _data)) {
                        _revert(TransferToNonERC721ReceiverImplementer.selector);
                    }
                } while (index < end);
                if (_currentIndex != end) _revert(bytes4(0));
            }
        }
    }

    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, '');
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _approve(to, tokenId, false);
    }

    function _approve(
        address to,
        uint256 tokenId,
        bool approvalCheck
    ) internal virtual {
        address owner = ownerOf(tokenId);

        if (approvalCheck && _msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                _revert(ApprovalCallerNotOwnerNorApproved.selector);
            }

        _tokenApprovals[tokenId].value = to;
        emit Approval(owner, to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        if (approvalCheck) {
            if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
                if (!isApprovedForAll(from, _msgSenderERC721A())) _revert(TransferCallerNotOwnerNorApproved.selector);
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        assembly {
            if approvedAddress {
                sstore(approvedAddressSlot, 0)
            }
        }

        unchecked {
            _packedAddressData[from] += (1 << _BITPOS_NUMBER_BURNED) - 1;

            _packedOwnerships[tokenId] = _packOwnershipData(
                from,
                (_BITMASK_BURNED | _BITMASK_NEXT_INITIALIZED) | _nextExtraData(from, address(0), prevOwnershipPacked)
            );

            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                if (_packedOwnerships[nextTokenId] == 0) {
                    if (nextTokenId != _currentIndex) {
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        unchecked {
            _burnCounter++;
        }
    }

    function _setExtraDataAt(uint256 index, uint24 extraData) internal virtual {
        uint256 packed = _packedOwnerships[index];
        if (packed == 0) _revert(OwnershipNotInitializedForExtraData.selector);
        uint256 extraDataCasted;
        assembly {
            extraDataCasted := extraData
        }
        packed = (packed & _BITMASK_EXTRA_DATA_COMPLEMENT) | (extraDataCasted << _BITPOS_EXTRA_DATA);
        _packedOwnerships[index] = packed;
    }

    function _extraData(
        address from,
        address to,
        uint24 previousExtraData
    ) internal view virtual returns (uint24) {}

    function _nextExtraData(
        address from,
        address to,
        uint256 prevOwnershipPacked
    ) private view returns (uint256) {
        uint24 extraData = uint24(prevOwnershipPacked >> _BITPOS_EXTRA_DATA);
        return uint256(_extraData(from, to, extraData)) << _BITPOS_EXTRA_DATA;
    }

    function _msgSenderERC721A() internal view virtual returns (address) {
        return msg.sender;
    }

    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            let m := add(mload(0x40), 0xa0)
            mstore(0x40, m)
            str := sub(m, 0x20)
            mstore(str, 0)

            let end := str

            for { let temp := value } 1 {} {
                str := sub(str, 1)
                mstore8(str, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            str := sub(str, 0x20)
            mstore(str, length)
        }
    }

    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}

contract Graveyard is ReentrancyGuard, Context, ERC721A, ERC721A__IERC721Receiver {

    address operator;
    mapping(IERC721A => uint256[]) IDs;
    mapping(address => uint256) TokenAmount;

    uint256 unburyAt = 1 days;

    bool public paused;

    // Tombstone Types
    mapping(uint256 => string) public Tombstones;
    mapping(uint256 => uint) public TombstonesType;

    // Zombie Types
    mapping(uint256 => string) public Zombies;
    mapping(uint256 => uint) public ZombiesType;

    mapping(address => uint256) public burials;

    mapping(address => uint256) public OwnerToID;
    mapping(uint256 => address) public IDToOwner;

    bool public zombieRequired = true;

    // Tokens Burried At
    mapping(address => mapping(address => uint256)) public buriedAmount;
    mapping(uint256 => uint256) public buriedTokenAt;
    mapping(address => address[]) tokensBuried;

    bool public fullSend = true;

    // Upgrade
    uint256 public upgradeFee = 0.05 ether;

    string site = 'https://rekt.kids';

    struct ZombiesMD {
        string Carl;
        string Morbelle;
        string Mortimer;
        string Rottus;
        string Griselda;
    }

    ZombiesMD public ZombieMD = ZombiesMD({
        Carl: string(abi.encodePacked(site, "/characters/Carl.json")),
        Morbelle: string(abi.encodePacked(site, "/characters/Morbelle.json")),
        Mortimer: string(abi.encodePacked(site, "/characters/Mortimer.json")),
        Rottus: string(abi.encodePacked(site, "/characters/Rottus.json")),
        Griselda: string(abi.encodePacked(site, "/characters/Griselda.json"))
    });
    
    ZombiesMD public TombstonesMD = ZombiesMD({
        Carl: string(abi.encodePacked(site, "/characters/CarlTombstone.json")),
        Morbelle: string(abi.encodePacked(site, "/characters/MorbelleTombstone.json")),
        Mortimer: string(abi.encodePacked(site, "/characters/MortimerTombstone.json")),
        Rottus: string(abi.encodePacked(site, "/characters/RottusTombstone.json")),
        Griselda: string(abi.encodePacked(site, "/characters/Griselda.json"))
    });

    modifier onlyOwner() {
        require(_msgSender() == operator);
        _;
    }

    constructor() ERC721A('Degen Graveyard', 'Rekt Zombies') {
        operator = _msgSender();
        Zombies[1] = string(abi.encodePacked(site, "/characters/Carl.json"));
        Zombies[2] = string(abi.encodePacked(site, "/characters/Morbelle.json"));
        Zombies[3] = string(abi.encodePacked(site, "/characters/Mortimer.json"));
        Zombies[4] = string(abi.encodePacked(site, "/characters/Rottus.json"));
        Zombies[5] = string(abi.encodePacked(site, "/characters/Griselda.json"));
        
        Tombstones[1] = string(abi.encodePacked(site, "/characters/CarlTombstone.json"));
        Tombstones[2] = string(abi.encodePacked(site, "/characters/MorbelleTombstone.json"));
        Tombstones[3] = string(abi.encodePacked(site, "/characters/MortimerTombstone.json"));
        Tombstones[4] = string(abi.encodePacked(site, "/characters/RottusTombstone.json"));
        Tombstones[5] = string(abi.encodePacked(site, "/characters/Griselda.json"));
    }

    function setZombies(uint zombieType, string memory _url) external onlyOwner {
        Zombies[zombieType] = _url;
    }
    
    function setTombstone(uint tombType, string memory _url) external onlyOwner {
        Tombstones[tombType] = _url;
    }

    function UnburyERC20(IERC20 token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(operator, balance);
        TokenAmount[address(token)] -= balance;
    }

    function UnburyERC721(IERC721A token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        for(uint i; i < balance; i++){
            token.safeTransferFrom(address(this), operator, IDs[token][i]);
            IDs[token][i] = 0;
            TokenAmount[address(token)]--;
        }
    }

    function BuryNFT721(IERC721A token, uint256[] memory tokenID) external nonReentrant {
        address _token = address(token);
        for(uint i; i < tokenID.length; i++){
            require(token.ownerOf(tokenID[i]) == _msgSender());
            token.safeTransferFrom(_msgSender(), address(this), tokenID[i]);
            IDs[token][TokenAmount[_token]] = tokenID[i];
        }
        
        if(balanceOf(msg.sender) > 0) {} else {
            TokenAmount[_token] += tokenID.length;
            _safeMint(msg.sender, 1);
        }

        OwnerToID[msg.sender] = totalSupply() - 1;
        tokensBuried[msg.sender].push(_token);
        buriedTokenAt[totalSupply() - 1] = block.timestamp;
        burials[msg.sender]++;
        buriedAmount[_token][msg.sender] = tokenID.length;
    }

    function _afterTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
    ) internal virtual override {
        super._afterTokenTransfers(from, to, startTokenId, quantity);
        uint256 _burials = burials[from];
        burials[to] += _burials;
        burials[from] -= _burials;
    }

    function BuryERC20(IERC20 token, uint256 amount) external nonReentrant {
        address _token = address(token);
        uint256 _amount = amount;
        require(_amount > 0, "Amount cannot be zero.");

        if(fullSend) require(token.balanceOf(_msgSender()) <= amount, "You must send all of your tokens.");

        token.transferFrom(msg.sender, address(this), amount);

        if(balanceOf(msg.sender) > 0) {

        } else {
            TokenAmount[_token] += _amount;
            _safeMint(msg.sender, 1);
        }

        OwnerToID[msg.sender] = totalSupply() - 1;
        tokensBuried[msg.sender].push(_token);
        buriedTokenAt[totalSupply() - 1] = block.timestamp + unburyAt;
        burials[msg.sender]++;
        buriedAmount[_token][msg.sender] = _amount;
    }

    function BuryERC20s(IERC20[] memory token, uint256[] memory amount) external nonReentrant {

        for(uint i; i < token.length; i++){
            
            address _token = address(token[i]);
            uint256 _amount = amount[i];
            require(_amount > 0, "Amount cannot be zero.");
            require(buriedAmount[_token][msg.sender] == 0, "Must be a unique token. You've buried this before.");
            if(fullSend) require(token[i].balanceOf(_msgSender()) <= _amount, "You must send all of your tokens.");
            token[i].transferFrom(msg.sender, address(this), _amount);
     
            tokensBuried[msg.sender].push(_token);
            buriedAmount[_token][msg.sender] = _amount;
            TokenAmount[_token] += _amount;
        }

        if(balanceOf(msg.sender) > 0) {

        } else {

            _safeMint(msg.sender, token.length);
        }

        OwnerToID[msg.sender] = totalSupply() - 1;

        buriedTokenAt[totalSupply() - 1] = block.timestamp + unburyAt;
        burials[msg.sender]++;

    }

    function getTier(uint256 number) public pure returns(uint256 tier) {
        if(number >= 10) return tier = 5;
        if(number >= 8) return tier = 4;
        if(number >= 4) return tier = 3;
        if(number >= 2) return tier = 2;
        if(number == 1) return tier = 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if(buriedTokenAt[tokenId] >= block.timestamp){
            return Tombstones[getTier(burials[ownerOf(tokenId)])];
        }else{
            return Zombies[getTier(burials[ownerOf(tokenId)])];
        }
    }

    struct UserInfo {
        uint256 burials;
        string zombie;
        address[] tokens;
    }
    
    function getBurials(address account) external view returns (UserInfo memory _burials) {
        _burials = UserInfo({
            burials: burials[account],
            zombie: Zombies[getTier(burials[account])],
            tokens: tokensBuried[account]
        });
    }

    function upgrade() external payable nonReentrant {
        if(zombieRequired) require(burials[msg.sender] > 0, "Must have buried a zombie.");
        require(msg.value >= upgradeFee, "Insufficient ETH Sent");
        burials[msg.sender] += 10;
    }

    function setSite(string memory _site) external onlyOwner {
        site = _site;
    }

    function setPaused(bool _paused) external onlyOwner {
        require(paused != _paused, "Already done.");
        paused = _paused;
    }

    function setZombieMD(uint256 _type, string calldata metadata) external onlyOwner {
        Zombies[_type] = string(abi.encodePacked(site, metadata));
    }

    function onERC721Received(address, address, uint256, bytes memory) public override virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function tokenRequirement(bool _send) external onlyOwner {
        fullSend = _send;
    }

    function zombieRequirement(bool _requireZombie) external onlyOwner {
        zombieRequired = _requireZombie;
    }

    function WithdrawETH() external onlyOwner {
        uint256 amountEth = address(this).balance;
        payable(_msgSender()).transfer(amountEth);
    }
}