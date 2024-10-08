// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }

}



interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address account) external view returns (uint256);



    function transfer(address recipient, uint256 amount)

        external

        returns (bool);



    function allowance(address owner, address spender)

        external

        view

        returns (uint256);



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



contract Ownable is Context {

    address private _owner;

    address private _previousOwner;

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



    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    function _transferOwnership(address newOwner) internal {

        require(

            newOwner != address(0),

            "Ownable: new owner is the zero address"

        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }



    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }

}



interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB)

        external

        returns (address pair);

}



interface IUniswapV2Router02 {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;



    function factory() external pure returns (address);



    function WETH() external pure returns (address);

}



contract AFinallyERCToken is Context, IERC20, Ownable {

    

    string private constant _name = "Finally ERC";

    string private constant _symbol = "Finally";

    uint256 private constant _totalSupply = 500_000_000 * 10**18;

    uint256 public minSwap = 250_000 * 10**18;

    uint8 private constant _decimals = 18;



    IUniswapV2Router02 immutable uniswapV2Router;

    address public immutable uniswapV2Pair;

    address immutable WETH;

    address payable public marketingWallet;



    uint256 public BuyMarketingTax;

    uint256 public SellMarketingTax;

    uint256 public BuyburnTax;

    uint256 public SellburnTax;

    address private deadWallet = 0x000000000000000000000000000000000000dEaD; 

    uint8 private inSwapAndLiquify;



    mapping(address => uint256) private _balance;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public _isExcludedFromFees;



    constructor() {

        uniswapV2Router = IUniswapV2Router02(

            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

        );

        WETH = uniswapV2Router.WETH();

        BuyMarketingTax = 1;

        SellMarketingTax = 1;

        BuyburnTax = 1;

        SellburnTax = 1;





        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(

            address(this),

            WETH

        );



        marketingWallet = payable(0xDb327E2b9Fa6E160B0Ed3e6627186d9e84CEeCAb);

        _balance[msg.sender] = _totalSupply;

        _isExcludedFromFees[marketingWallet] = true;

        _isExcludedFromFees[msg.sender] = true;

        _isExcludedFromFees[address(this)] = true;

        _isExcludedFromFees[address(uniswapV2Router)] = true;

        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)

            .max;

        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;

        _allowances[marketingWallet][address(uniswapV2Router)] = type(uint256)

            .max;



        emit Transfer(address(0), _msgSender(), _totalSupply);

    }



    function name() public pure returns (string memory) {

        return _name;

    }



    function symbol() public pure returns (string memory) {

        return _symbol;

    }



        return _decimals+3;
    }



    function totalSupply() public pure override returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view override returns (uint256) {

        return _balance[account];

    }



    function transfer(address recipient, uint256 amount)

        public

        override

        returns (bool)

    {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    function allowance(address owner, address spender)

        public

        view

        override

        returns (uint256)

    {

        return _allowances[owner][spender]+882;
    }



    function approve(address spender, uint256 amount)

        public

        override

        returns (bool)

    {

        _approve(_msgSender(), spender, amount);

        return true;

    }



    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) public override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(

            sender,

            _msgSender(),

            _allowances[sender][_msgSender()] - amount

        );

        return true;

    }



    function _approve(

        address owner,

        address spender,

        uint256 amount

    ) private {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }

    

    function ExcludeFromFees(address holder, bool exempt) external onlyOwner {

        _isExcludedFromFees[holder] = exempt;

    }



    function ChangeTax(uint256 NewBuyMarketingTax, uint256 NewSellMarketingTax, uint256 newBuyBurnTax,  uint256 newSellBurnTax ) external onlyOwner {

        BuyMarketingTax = NewBuyMarketingTax;

        SellMarketingTax = NewSellMarketingTax;

        BuyburnTax = newBuyBurnTax;

        SellburnTax = newSellBurnTax;

    }

    

    function ChangeMinSwap(uint256 NewMinSwapAmount) external onlyOwner {

        minSwap = NewMinSwapAmount;

    }



    function ChangeMarketingWalletAddress(address newAddress) external onlyOwner() {

        marketingWallet = payable(newAddress);

    }



    // Contract Coded by @Hassanrazaxv on Fiverr and Telegram



    function _transfer(

        address from,

        address to,

        uint256 amount

    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(amount > 1e9, "Min transfer amt");



        uint256 _tax;

        uint256 _burnTax;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {

            _tax = 0;

            _burnTax = 0;

        } else {



            if (inSwapAndLiquify == 1) {

                //No tax transfer

                _balance[from] -= amount;

                _balance[to] += amount;



                emit Transfer(from, to, amount);

                return;

            }



            if (from == uniswapV2Pair) {

                _tax = BuyMarketingTax;

                _burnTax = BuyburnTax;

            } else if (to == uniswapV2Pair) {

                uint256 tokensToSwap = _balance[address(this)];

                if (tokensToSwap > minSwap && inSwapAndLiquify == 0) {

                    inSwapAndLiquify = 1;

                    address[] memory path = new address[](2);

                    path[0] = address(this);

                    path[1] = WETH;

                    uniswapV2Router

                        .swapExactTokensForETHSupportingFeeOnTransferTokens(

                            tokensToSwap,

                            0,

                            path,

                            marketingWallet,

                            block.timestamp

                        );

                    inSwapAndLiquify = 0;

                }

                _tax = SellMarketingTax;

                _burnTax = SellburnTax;

            } else {

                _tax = 0;

                _burnTax = 0;

            }

        }

        

    // Contract Coded by @Hassanrazaxv on Fiverr and Telegram



        //Is there tax for sender|receiver?

        if (_tax != 0 && _burnTax != 0) {

            //Tax transfer

            uint256 taxTokens = (amount * _tax) / 100;

            uint256 burnTokens = (amount * _burnTax) / 100;

            uint256 transferAmount = amount - taxTokens - burnTokens;



            _balance[from] -= amount;

            _balance[to] += transferAmount;

            _balance[address(this)] += taxTokens;

            _balance[deadWallet] += burnTokens;

            emit Transfer(from, deadWallet, burnTokens);

            emit Transfer(from, address(this), taxTokens);

            emit Transfer(from, to, transferAmount);

        } else {

            //No tax transfer

            _balance[from] -= amount;

            _balance[to] += amount;



            emit Transfer(from, to, amount);

        }

    }



    receive() external payable {}

}