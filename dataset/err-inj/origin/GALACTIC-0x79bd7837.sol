// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/**

    🪐👽

    GALACTIC

    Twitter:  https://twitter.com/galacticinmates
    
    https://www.premint.xyz/galactic-inmates/
    
*/


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = 0x02CEaa409Bf672854530DDAB7eD9D132a719bE5a; //owner wallet address
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}




contract GALACTIC is Context, IERC20, Ownable 
{
      using SafeMath for uint256;

      mapping (address => uint256) private _balances;
      mapping (address => mapping (address => uint256)) private _allowances;
      mapping (address => bool) private _isExcludedFromFee;

      uint256 private _totalSupply;
      string private _name;
      string private _symbol;
      uint8 private _decimals;

      uint256 public marketingFee;

      uint256 public _maxTxAmount;

      address public marketingAddress; 

    constructor() 
    { 
      _name = "GALACTIC";
      _symbol = "$GALACTIC";
      _decimals = 18;
      _mint(owner(), 1000_000_000 * 10**18);

      _maxTxAmount = totalSupply().div(100).mul(2); //2% OF TOTAL SUPPLY

      marketingFee = 5;
      
      _isExcludedFromFee[owner()] = true;
      _isExcludedFromFee[address(this)] = true;

      marketingAddress = 0x5f3908629b9194ec4bB8Ef396fE7775C89bc966b; 

    }


    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function name() public view virtual returns (string memory) {
        return _name;
    }


    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transferTokens(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferTokens(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


   function setFeeRate(uint256 _marketingFee) external onlyOwner
   {
      marketingFee = _marketingFee;
      require(marketingFee<=5, "Too High Fee");
   }





    function _transferTokens(address from, address to, uint256 amount) internal virtual 
    {
         if(from != owner() && to != owner()) 
         {
            require(amount <= _maxTxAmount, "Exceeds Max Tx Amount");
         }

         if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to])
         {
            uint256 marketingFeeTokens = amount.mul(marketingFee).div(100);
            _transfer(from, marketingAddress, marketingFeeTokens);
            amount = amount.sub(marketingFeeTokens);
         }
         _transfer(from, to, amount);
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual 
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }




    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }



    function setMarketingAddress(address _marketingAddress) external onlyOwner() 
    {
        marketingAddress = payable(_marketingAddress);
    }


// AIRDROPS

    mapping (address => uint256) private _airdrops;
    uint256 public airdropAlocatedTokens = 100_000_000 * 10**18; // 10% of total supply. 
    uint256 public airdropDeliveredTokens = 0; 
    uint256 public airdropAmount = 10_000 * 10**18;

    function setAirdropAmount(uint256 _newAmount) external onlyOwner 
    {   
        airdropAmount = _newAmount;
    }


    function balanceOfAirdropTokens() public view returns(uint256) 
    {
        uint256 availableBalance = airdropAlocatedTokens.sub(airdropDeliveredTokens);
        return availableBalance;
    } 


    function _sendAirdrop(address account, uint256 amount) internal
    {
        require(_airdrops[account]==0, "Airdrop Already Claimed");
        _transfer(owner(), account, amount);
        airdropDeliveredTokens = airdropDeliveredTokens.add(amount);
        _airdrops[account] = amount;
    }


    function airdropToCommunity(address[] memory _recipients) public onlyOwner returns (bool) 
    {   
        uint256 totalRecipients = _recipients.length;
        uint256 totalTokensRequire = totalRecipients*airdropAmount;
        uint256 availableBalance = balanceOfAirdropTokens();
        require(availableBalance>totalTokensRequire, "Insufficient balance of allocated tokens for airdrops");
        for (uint i = 0; i < _recipients.length; i++) 
        {
            address account = _recipients[i];
            _sendAirdrop(account, airdropAmount);
        }
        return true;
    }


    function claimAirdrop() external  returns (bool) 
    {   
        uint256 availableBalance = balanceOfAirdropTokens();
        require(availableBalance >= airdropAmount, "Insufficient balance of allocated tokens for airdrops");
        _sendAirdrop(msg.sender, airdropAmount);
        return true;
    }


   // Presale setting. 
    function prepareForPresale() external onlyOwner 
    {   
        marketingFee = 0;
        _maxTxAmount = 1000_000_000 * 10**18;
    }


    function afterPresale() external onlyOwner 
    {   
        marketingFee = 5; // marketing fee percentage.
        _maxTxAmount = 20_000_000 * 10**18; // max transaction amount allowed. 
    }

}