// SPDX-License-Identifier: MIT

// Dual Staking contract for DeFi Platform. Easy access for projects to have asset to asset staking earning interest based on APY % 
// from token to another desired token or currency from the same chain.

pragma solidity ^0.8.2;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor(address _owner) {
        owner = _owner;
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// Using consensys implementation of ERC-20, because of decimals

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

abstract contract EIP20Interface {
    /* This is a slight change to the EIP20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance The balance
    function balanceOf(address _owner) virtual public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) virtual public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender, uint256 _value) virtual public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
*/

contract EIP20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) override public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
        uint256 the_allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && the_allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (the_allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) override public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) override public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) override public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

/**
 * 
 * Dual Staking is an interest gain contract for ERC-20 tokens to earn revenue staking token A and earn token B
 * 
 * asset is the EIP20 token to deposit in
 * asset2 is the EIP20 token to get interest in
 * interest_rate: percentage earning rate of token1 based on APY (annual yield)
 * interest_rate2: percentage earning rate of token2 based on APY (annual yield)
 * maturity is the time in seconds after which is safe to end the stake
 * penalization is for ending a stake before maturity time of the stake taking loss quitting the commitment
 * lower_amount is the minimum amount for creating the stake in tokens
 * 
 */
contract DualStaking is Owner, ReentrancyGuard {

    // Token to deposit
    EIP20 public asset;

    // Token to pay interest in | (Can be the same but suggested to use Single Staking for this)
    EIP20 public asset2;

    // stakes history
    struct Record {
        uint256 from;
        uint256 amount;
        uint256 gain;
        uint256 gain2;
        uint256 penalization;
        uint256 to;
        bool ended;
    }

    // contract parameters
    uint16 public interest_rate;
    uint16 public interest_rate2;
    uint256 public maturity;
    uint8 public penalization;
    uint256 public lower_amount;

    // conversion ratio for token1 and token2
    // 1:10 ratio will be: 
    // ratio1 = 1 
    // ratio2 = 10
    uint256 public ratio1;
    uint256 public ratio2;

    mapping(address => Record[]) public ledger;

    event StakeStart(address indexed user, uint256 value, uint256 index);
    event StakeEnd(address indexed user, uint256 value, uint256 penalty, uint256 interest, uint256 index);
    
    constructor(
        EIP20 _erc20, EIP20 _erc20_2, address _owner, uint16 _rate, uint16 _rate2, uint256 _maturity, 
        uint8 _penalization, uint256 _lower, uint256 _ratio1, uint256 _ratio2) Owner(_owner) {
        require(_penalization<=100, "Penalty has to be an integer between 0 and 100");
        asset = _erc20;
        asset2 = _erc20_2;
        ratio1 = _ratio1;
        ratio2 = _ratio2;
        interest_rate = _rate;
        interest_rate2 = _rate2;
        maturity = _maturity;
        penalization = _penalization;
        lower_amount = _lower;
    }
    
    function start(uint256 _value) external nonReentrant {
        require(_value >= lower_amount, "Invalid value");
        require(asset.transferFrom(msg.sender, address(this), _value));
        ledger[msg.sender].push(Record(block.timestamp, _value, 0, 0, 0, 0, false));
        emit StakeStart(msg.sender, _value, ledger[msg.sender].length-1);
    }

    function end(uint256 i) external nonReentrant {

        require(i < ledger[msg.sender].length, "Invalid index");
        require(ledger[msg.sender][i].ended==false, "Invalid stake");
        
        // penalization
        if(block.timestamp - ledger[msg.sender][i].from < maturity) {

            uint256 _penalization = ledger[msg.sender][i].amount * penalization / 100;
            require(asset.transfer(msg.sender, ledger[msg.sender][i].amount - _penalization));
            require(asset.transfer(getOwner(), _penalization));
            ledger[msg.sender][i].penalization = _penalization;
            ledger[msg.sender][i].to = block.timestamp;
            ledger[msg.sender][i].ended = true;
            emit StakeEnd(msg.sender, ledger[msg.sender][i].amount, _penalization, 0, i);

        // interest gained
        } else {
            
            // interest is calculated in asset2
            uint256 _interest = get_gains(msg.sender, i);

            // check that the owner can pay interest before trying to pay, token 1
            if (_interest>0 && asset.allowance(getOwner(), address(this)) >= _interest && asset.balanceOf(getOwner()) >= _interest) {
                require(asset.transferFrom(getOwner(), msg.sender, _interest));
            } else {
                _interest = 0;
            }

            // interest is calculated in asset2
            uint256 _interest2 = get_gains2(msg.sender, i);

            // check that the owner can pay interest before trying to pay, token 1
            if (_interest2>0 && asset2.allowance(getOwner(), address(this)) >= _interest2 && asset2.balanceOf(getOwner()) >= _interest2) {
                require(asset2.transferFrom(getOwner(), msg.sender, _interest2));
            } else {
                _interest2 = 0;
            }

            // the original asset is returned to the investor
            require(asset.transfer(msg.sender, ledger[msg.sender][i].amount));
            ledger[msg.sender][i].gain = _interest;
            ledger[msg.sender][i].gain2 = _interest2;
            ledger[msg.sender][i].to = block.timestamp;
            ledger[msg.sender][i].ended = true;
            emit StakeEnd(msg.sender, ledger[msg.sender][i].amount, 0, _interest, i);

        }
    }

    function set(EIP20 _erc20, EIP20 _erc20_2, uint256 _lower, uint256 _maturity, uint16 _rate, uint16 _rate2, uint8 _penalization, uint256 _ratio1, uint256 _ratio2) external isOwner {
        require(_penalization<=100, "Invalid value");
        asset = _erc20;
        asset2 = _erc20_2;
        ratio1 = _ratio1;
        ratio2 = _ratio2;
        lower_amount = _lower;
        maturity = _maturity;
        interest_rate = _rate;
        interest_rate2 = _rate2;
        penalization = _penalization;
    }

    // calculate interest of the token 1 to the current date time
    function get_gains(address _address, uint256 _rec_number) public view returns (uint256) {
        uint256 _record_seconds = block.timestamp - ledger[_address][_rec_number].from;
        uint256 _year_seconds = 365*24*60*60;
        return _record_seconds * 
            ledger[_address][_rec_number].amount * interest_rate / 100
        / _year_seconds;
    }

    // calculate interest to the current date time
    function get_gains2(address _address, uint256 _rec_number) public view returns (uint256) {
        uint256 _record_seconds = block.timestamp - ledger[_address][_rec_number].from;
        uint256 _year_seconds = 365*24*60*60;
        
        /**
         *
         * Oririginal code:
         * 
         *   // now we calculate the value of the transforming the staked asset (asset) into the asset2
         *   // first we calculate the ratio
         *   uint256 value_in_asset2 = ledger[_address][_rec_number].amount * ratio2 / ratio1;
         *   // now we transform into decimals of the asset2
         *   value_in_asset2 = value_in_asset2 * 10**asset2.decimals() / 10**asset.decimals();
         *   uint256 interest = _record_seconds * value_in_asset2 * interest_rate2 / 100 / _year_seconds;
         *   // now lets calculate the interest rate based on the converted value in asset 2
         *
         * Simplified into:
         * 
         */

        return (_record_seconds * ledger[_address][_rec_number].amount * ratio2 * 10**asset2.decimals() * interest_rate2) / 
               (ratio1 * 10**asset.decimals() * 100 * _year_seconds);

    }

    function ledger_length(address _address) external view 
        returns (uint256) {
        return ledger[_address].length;
    }

}