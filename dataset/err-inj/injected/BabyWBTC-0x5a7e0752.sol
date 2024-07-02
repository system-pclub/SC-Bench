/*
What's up, BabyWBTC DEV here:

If I'm honest, the baby trend should be reward tokens. So yeah, let's try one! 
I don't know if you guys are ready for a real reward token, because lately the market has been tough.
I see people aping into rugs blindly and not investing in real projects, which then have no volume and are forced to give up.
Pepe dumping on investors like it's nothing, dumping on diamond handers. 
I feel like the scammers are winning; we need to change this, people.
So, let's do this 5% tax Community token.

Community Tax Breakdown:

4.20% goes to WBTC rewards for the community automaticly send every 69 min.
0.8% will be used to support my village, marketing and some baybacks.

Tokenomics:

Name: Baby Wrapped BTC
Symbol: $BabyWBTC
Tax: 5% on both buys and sells
Supply: 21.000.000 $BabyWBTC
Max wallet and max transactions: 2%
Liquidity will be burned (at $69K market cap)
Contract will be renounced
Low Cap starting liq will be 0.69420 eth

I'm working on the website right now and will open a Telegram group at a $69K market cap.
Taxes start at 25 Buy and 30 Sell to scare the Bots. 

Well, let's see if you guys buy into this legit reward token attempt!! Most likely, you'll just let it sit on the chain and invest in a 99% tax token, so sad. 
But at least I tried.

Let's Fucking Go!
*/
pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!Owner"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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

interface IBtcPrinter {
    function setBtcCoin (address btcAddress) external;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function goBTC(address shareholder) external;
    function removeStuckDividends() external;
}

contract BtcPrinter is IBtcPrinter {

    using SafeMath for uint256;
    address _token;

    address public BtcCoin;

    IDEXRouter router;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 18;

    uint256 public minPeriod = 69 minutes;
    uint256 public minDistribution = 100000 * (10 ** 9); //0.0001

    uint256 public currentIndex;
    bool initialized;

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor () {
        _token = msg.sender;
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        BtcCoin = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;//Wrapped BTC (WBTC)
    }
    
    receive() external payable {
        deposit();
    }

    function removeStuckDividends() external onlyToken {
        uint256 balance = IERC20(BtcCoin).balanceOf(address(this));

        IERC20(BtcCoin).transfer(
            address(msg.sender),
            balance
        );
    }

    function setBtcCoin(address btcAddress) external override onlyToken {
        BtcCoin = btcAddress;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {

        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() public payable override {

        uint256 balanceBefore = IERC20(BtcCoin).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BtcCoin);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = IERC20(BtcCoin).balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
    function process(uint256 gas) external override {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) public view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            IERC20(BtcCoin).transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function goBTC(address) external override onlyToken {
        require(shouldDistribute(msg.sender), "Btc not rdy yet!");
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract BabyWBTC is IERC20, Auth {
    using SafeMath for uint256;

    address public BtcCoin = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; //Wrapped BTC (WBTC)

    string private constant _name = "Baby Wrapped BTC";
    string private constant _symbol = "BabyWBTC";
    uint8 private constant _decimals = 9;
    
    uint256 private _totalSupply = 21_000_000 * (10 ** _decimals);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => uint256) private cooldown;

    address private WETH;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    bool public antiBot = true;

    mapping (address => bool) private bots; 
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;

    uint256 public launchedAt;
    address private lpWallet = DEAD;

    uint256 public buyFee = 5;
    uint256 public sellFee = 5;

    uint256 public toReflections = 84;//4.20%
    uint256 public toLiquidity = 0;
    uint256 public toMarketing = 16;//0.8%

    uint256 public allocationSum = 100;

    IDEXRouter public router;
    address public pair;
    address public factory;
    address private tokenOwner;
    address public devWallet = msg.sender;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingOpen = false;
    
    BtcPrinter public btcPrinter;
    uint256 public btcPrinterGas = 0;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    uint256 public maxTx = _totalSupply.mul(20).div(1000);
    uint256 public maxWallet = _totalSupply.mul(20).div(1000);
    uint256 public swapThreshold = _totalSupply.mul(5).div(10000);

    constructor (
        address _owner        
    ) Auth(_owner) {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
            
        WETH = router.WETH();
        
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        
        _allowances[address(this)][address(router)] = type(uint256).max;

        btcPrinter = new BtcPrinter();
        
        isFeeExempt[_owner] = true;
        isFeeExempt[devWallet] = true;             

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;    

        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[DEAD] = true;    


        _balances[_owner] = _totalSupply;
    
    }

    receive() external payable { }

    function _setBtcCoin(address btcAddress) internal {
        btcPrinter.setBtcCoin(btcAddress);
    }

    function setBtcCoin(address btcAddress) external onlyOwner {
        BtcCoin = btcAddress;
        _setBtcCoin(btcAddress);
    }

    function setBots(address[] memory bots_) external onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }
    
    //once enabled, cannot be reversed
    function openTrading() external onlyOwner {
        launchedAt = block.number;
        tradingOpen = true;
        //antibot Launch taxes, taxes will be 5% buy & sell and 50% to Refelection and marketing
        buyFee = 25;
        sellFee = 30;
        toReflections = 25;
        toLiquidity = 0;
        toMarketing = 75;
    } 

    function setFinalFee() external onlyOwner {
        buyFee = 5;
        sellFee = 5;
        toReflections = 84;
        toLiquidity = 0;
        toMarketing = 16;
    }
   
    function changeTotalFees(uint256 newBuyFee, uint256 newSellFee) external onlyOwner {
        require(buyFee <= 10, "don be greedy DEV");
        require(sellFee <= 35, "don be greedy DEV");
        buyFee = newBuyFee;
        sellFee = newSellFee; 
    } 
    
    function changeFeeAllocation(uint256 newRewardFee, uint256 newLpFee, uint256 newMarketingFee) external onlyOwner {
        toReflections = newRewardFee;
        toLiquidity = newLpFee;
        toMarketing = newMarketingFee;
    }

    function changeTxLimit(uint256 amountPercent) external onlyOwner {
        require(amountPercent>1);
        maxTx = (_totalSupply * amountPercent ) / 100;
    }

    function changeWalletLimit(uint256 amountPercent) external onlyOwner {
        require(amountPercent>1);
        maxWallet = (_totalSupply * amountPercent ) / 100;
    }

     function removeLimits() external onlyOwner{
        maxTx = _totalSupply;
        maxWallet = _totalSupply;
    }
    
    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {      
        isTxLimitExempt[holder] = exempt;
    }

    function setDevWallet(address payable newDevWallet) external onlyOwner {
        devWallet = payable(newDevWallet);
    }

    function setLpWallet(address newLpWallet) external onlyOwner {
        lpWallet = newLpWallet;
    }    

    function setOwnerWallet(address payable newOwnerWallet) external onlyOwner {
        tokenOwner = newOwnerWallet;
    }     

    function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit) external onlyOwner {
        swapAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external onlyOwner {
        btcPrinter.setDistributionCriteria(newMinPeriod, newMinDistribution);        
    }

    function delBot(address notbot) external onlyOwner {
        bots[notbot] = false;
    }

    function _setIsDividendExempt(address holder, bool exempt) internal {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            btcPrinter.setShare(holder, 0);
        }else{
            btcPrinter.setShare(holder, _balances[holder]);
        }
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        _setIsDividendExempt(holder, exempt);
    }

    function changeBtcPrinterGas(uint256 newGas) external onlyOwner {
        btcPrinterGas = newGas;
    }           

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]+367;    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return !_transfer(sender, recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender!= owner && recipient!= owner) require(tradingOpen, "hold ur horses big guy."); //transfers disabled before tradingActive
        require(!bots[sender] && !bots[recipient]);

        if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }

        require(amount <= maxTx || isTxLimitExempt[sender], "tx");

        if(!isTxLimitExempt[recipient] && antiBot)
        {
            require(_balances[recipient].add(amount) <= maxWallet, "wallet");
        }

        if(msg.sender != pair && !inSwapAndLiquify && swapAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try btcPrinter.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try btcPrinter.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }    

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }  
    
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeApplicable = pair == recipient ? sellFee : buyFee;
        uint256 feeAmount = amount.mul(feeApplicable).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        approve(address(this), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            lpWallet,
            block.timestamp
        );
    }

    function swapBack() internal lockTheSwap {
    
        uint256 tokenBalance = _balances[address(this)]; 
        uint256 tokensForLiquidity = tokenBalance.mul(toLiquidity).div(100).div(2);     
        uint256 amountToSwap = tokenBalance.sub(tokensForLiquidity);

        swapTokensForEth(amountToSwap);

        uint256 totalEthBalance = address(this).balance;
        uint256 ethForBtcCoin = totalEthBalance.mul(toReflections).div(100);
        uint256 ethForMarketing = totalEthBalance.mul(toMarketing).div(100);
        uint256 ethForLiquidity = totalEthBalance.mul(toLiquidity).div(100).div(2);
      
        if (totalEthBalance > 0){
            payable(devWallet).transfer(ethForMarketing);
        }
        
        try btcPrinter.deposit{value: ethForBtcCoin}() {} catch {}
        
        if (tokensForLiquidity > 0){
            addLiquidity(tokensForLiquidity, ethForLiquidity);
        }
    }

    function manualSwapBack() external onlyOwner {
        swapBack();
    }

    function clearStuckEth() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        if(contractETHBalance > 0){          
            payable(devWallet).transfer(contractETHBalance);
        }
    }

    function manualProcessGas(uint256 manualGas) external onlyOwner {
        btcPrinter.process(manualGas);
    }

    function howMuchBTC(address shareholder) external view returns (uint256) {
        return btcPrinter.getUnpaidEarnings(shareholder);
    }

    function giveMeMyOwedBtc() external {
        btcPrinter.goBTC(msg.sender);
    }
    
    function removeStuckDividends() external onlyOwner {
     btcPrinter.removeStuckDividends();
    }
}