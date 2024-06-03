// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract PEPESTAKE {
    using SafeMath for uint256;
    IERC20 public stakeToken; //

    address payable public owner;

    bool public paused;
    uint256 public maxStakeableToken;
    uint256 public minimumStakeToken;
    uint256 public totalUnStakedToken;
    uint256 public totalStakedToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider;
    uint256 public totalFee;

    uint256[5] public Duration = [7 days, 14 days, 30 days];  // These are token locking periods; we may also enter a number of seconds here
    uint256[5] public Bonus = [50, 120, 350]; // These bonus variables are related to duration and the amount will be multiplied by 10 for example 10 percent is equals to 100

    struct Stake {
        uint256 unstaketime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 lastharvesttime;
        uint256 remainingreward;
        uint256 harvestreward;
        uint256 persecondreward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalUnstakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        bool alreadyExists;
    }

    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;

    event STAKE(address Staker, uint256 amount);
    event HARVEST(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);



    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }
    constructor(address payable _owner, address st) {
        owner = _owner; // Address of contract owner
        stakeToken = IERC20(st); // Address of the token 
        totalFee = 0; // Fee percentage if the token takes a fee on transactions (multiply by 10)
        maxStakeableToken = 1e25; // This is the the maximum limit that a user can stake
        percentDivider = 1000;
        minimumStakeToken = 1e18; // This is the minimum that a user can stake
        paused = false;
    }

    /** This function is used for staking */
    function stake(uint256 amount1, uint256 timeperiod) public whenNotPause{
        require(timeperiod >= 0 && timeperiod <= 2, "Invalid time period");
        require(amount1 >= minimumStakeToken && amount1 <= maxStakeableToken, "stake amount should be in set range");
        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));  // If the token has fees, it calculates the amount that goes into the contract
        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }

        stakeToken.transferFrom(msg.sender, address(this), amount1);

        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].unstaketime = block.timestamp.add(
            Duration[timeperiod]
        );
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].reward = amount
            .mul(Bonus[timeperiod])
            .div(percentDivider);
        stakersRecord[msg.sender][index].persecondreward = stakersRecord[
            msg.sender
        ][index].reward.div(Duration[timeperiod]);
        stakersRecord[msg.sender][index].lastharvesttime = 0;
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].reward;
        stakersRecord[msg.sender][index].harvestreward = 0;
        Stakers[msg.sender].stakeCount++;

        emit STAKE(msg.sender, amount);
    }

    /** After the locking time has expired, the user will be free to unstake the token, and any remaining reward will be withdrawn as well */

    function unstake(uint256 index) public {
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        require(
            stakersRecord[msg.sender][index].unstaketime < block.timestamp,
            "You cannot unstake before staking duration ends"
        );

        if(!stakersRecord[msg.sender][index].withdrawan){
            harvest(index);
        }
        stakersRecord[msg.sender][index].unstaked = true;

        stakeToken.transfer(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
        
        totalUnStakedToken = totalUnStakedToken.add(
            stakersRecord[msg.sender][index].amount
        );
        Stakers[msg.sender].totalUnstakedTokenUser = Stakers[msg.sender]
            .totalUnstakedTokenUser
            .add(stakersRecord[msg.sender][index].amount);

        emit UNSTAKE(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
    }

    /** This function will harvest reward in realtime */
    function harvest(uint256 index) public {
        require(
            !stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        uint256 rewardTillNow;
        uint256 commontimestamp;
        (rewardTillNow,commontimestamp) = realtimeRewardPerStake(msg.sender , index);
        stakersRecord[msg.sender][index].lastharvesttime =  commontimestamp;
        stakeToken.transfer(
            msg.sender,
            rewardTillNow
        );
        totalClaimedRewardToken = totalClaimedRewardToken.add(
            rewardTillNow
        );
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].remainingreward.sub(rewardTillNow);
        stakersRecord[msg.sender][index].harvestreward = stakersRecord[msg.sender][index].harvestreward.add(rewardTillNow);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(rewardTillNow);

        if(stakersRecord[msg.sender][index].harvestreward == stakersRecord[msg.sender][index].reward){
            stakersRecord[msg.sender][index].withdrawan = true;
        }

        emit HARVEST(
            msg.sender,
            rewardTillNow
        );
    }

    /** This function will return real time rerward of particular user's every stakeRecord */
    function realtimeRewardPerStake(address user, uint256 stakeIndex) public view returns (uint256,uint256) {
        uint256 ret;
        uint256 commontimestamp;
            if (
                !stakersRecord[user][stakeIndex].withdrawan &&
                !stakersRecord[user][stakeIndex].unstaked
            ) {
                uint256 val;
                uint256 tempharvesttime = stakersRecord[user][stakeIndex].lastharvesttime;
                commontimestamp = block.timestamp;
                if(tempharvesttime == 0){
                    tempharvesttime = stakersRecord[user][stakeIndex].staketime;
                }
                val = commontimestamp - tempharvesttime;
                val = val.mul(stakersRecord[user][stakeIndex].persecondreward);
                if (val < stakersRecord[user][stakeIndex].remainingreward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][stakeIndex].remainingreward;
                }
            }
        return (ret,commontimestamp);
    }

     /** This function will return real time rerward of particular user's every block */

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < Stakers[user].stakeCount; i++) {
            if (
                !stakersRecord[user][i].withdrawan &&
                !stakersRecord[user][i].unstaked
            ) {
                uint256 val;
                val = block.timestamp - stakersRecord[user][i].staketime;
                val = val.mul(stakersRecord[user][i].persecondreward);
                if (val < stakersRecord[user][i].reward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][i].reward;
                }
            }
        }
        return ret;
    }

    function pauseContract()public onlyowner whenNotPause{
        paused = true;
    }

    function unpauseContract()public onlyowner whenPause{
        paused = false;
    }

    modifier whenPause() {
        require(paused == true, "Contract is UnPaused");
        _;
    }

    modifier whenNotPause() {
        require(paused == false, "Contract is Paused");
        _;
    }

    /** Using this function, the contract's owner can adjust the minimum and maximum stake limits. We can also eliminate this method, which has no effect on the computation */
    function SetStakeLimits(uint256 _min, uint256 _max) external onlyowner {
        minimumStakeToken = _min;
        maxStakeableToken = _max;
    }

    /** If the percentage of token fees changes, the owner must update using this method, and the value will be multiplied by 10 */
    function SetTotalFees(uint256 _fee) external onlyowner {
        totalFee = _fee;
    }
    /** This method may only be invoked by the owner's address and is used to adjust the stake duration (locking period), the argument will be in seconds */
    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third
    ) external onlyowner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
    }

    /** This method is used to base currency */

    function withdrawBaseCurrency() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }
    /** These two methods will enable the owner in withdrawing any incorrectly deposited tokens
    * first call initToken method, passing the token contract address as an argument
    * then call withdrawToken with the value in wei as an argument */
    function withdrawToken(address addr,uint256 amount) public onlyowner {
        IERC20(addr).transfer(msg.sender
        , amount);
    }

    receive() payable external {}
}