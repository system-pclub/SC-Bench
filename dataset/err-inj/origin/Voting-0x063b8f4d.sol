// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner {
        require(isOwner(msg.sender));
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) internal onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function isOwner(address addr) public view returns (bool) {
        return owner == addr;
    }
}

library Uint256Helpers {
    uint256 private constant MAX_UINT64 = type(uint256).max;

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {
        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}

contract TimeHelpers {
    using Uint256Helpers for uint256;

    /**
    * @dev Returns the current block number.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    /**
    * @dev Returns the current block number, converted to uint64.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber64() internal view returns (uint64) {
        return getBlockNumber().toUint64();
    }

    /**
    * @dev Returns the current timestamp.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp; // solium-disable-line security/no-block-members
    }

    /**
    * @dev Returns the current timestamp, converted to uint64.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function totalSupplyAt(uint256 blockNumber) external view returns (uint256);
    function balanceOfAt(address account, uint blockNumber) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Voting is Ownable,TimeHelpers{
    using Uint256Helpers for uint256;
    struct VoteOption {
        string description;
        uint256 votedPower;
    }

    struct VoteWeight {
        uint64 weight;
        uint256 votedPower;
    }

    struct Vote {
        bool open;
        uint64 startTime;
        uint64 endTime;
        string title;
        string description;
        uint64 snapshotBlock;
        uint256 votingPower;
        VoteOption[] voteOptions;
        mapping (address => mapping (uint64 => VoteWeight)) voters;//address/option/weight
    }

    mapping (uint256 => Vote) public _voteLists; 
    address public _deputy;
    address public _veToken;

    event StartVote(uint256 voteId, address creator, uint64 startTime, uint64 endTime, string title, string desc, string[] optionDescs);
    event CastVote(uint256  voteId, address voter, uint64 optionId, uint64 weight, uint256 votedPower);
    event CloseVote(uint256 voteId, address sender, string memo);

    constructor(address veToken){
        _veToken = veToken;
		transferOwnership(msg.sender);
	}    

    function newVote(uint256 voteId, uint64 startTime, uint64 endTime, string memory title, string memory desc, string[] memory optionDescs) public {
        require(msg.sender == _deputy, "only deputy can do this");
        require(_voteLists[voteId].snapshotBlock == 0, "vote exist");
        uint64 snapshotBlock = getBlockNumber64();
        Vote storage vote_ = _voteLists[voteId];
        vote_.snapshotBlock = snapshotBlock;
        vote_.startTime = startTime;
        vote_.endTime = endTime;
        vote_.title = title;
        vote_.description = desc;
        for(uint8 i = 0; i < optionDescs.length; i++){
            VoteOption memory item = VoteOption(optionDescs[i], 0);
            vote_.voteOptions.push(item);
        }
        vote_.votingPower = IERC20(_veToken).totalSupplyAt(snapshotBlock);
        vote_.open = true;
        emit StartVote(voteId, msg.sender, startTime, endTime, title, desc, optionDescs);
    }

    function castVote(uint256 voteId, uint64[] memory optionIds, uint64[] memory weights) public {
        Vote storage vote_ = _voteLists[voteId];
        require(vote_.snapshotBlock > 0, "vote not exist");
        require(vote_.open, "vote closed");
        require(block.timestamp < vote_.endTime && block.timestamp > vote_.startTime, "wrong time");        
        uint256 balance = IERC20(_veToken).balanceOfAt(msg.sender, vote_.snapshotBlock);
        require(balance > 0, "balance=0");
        uint64 optionCount = vote_.voteOptions.length.toUint64();
        for(uint64 i = 0; i < weights.length; i++){
            uint64 optionId = optionIds[i];
            uint64 weight = weights[i];
            require(weight > 0, "weight=0");            
            require(optionId < optionCount, "wrong optionId");
            uint64 sumWeight = 0;            
            for(uint64 j = 0; j < optionCount; j++){
                sumWeight += vote_.voters[msg.sender][j].weight;
            }
            require(sumWeight + weight <= 10000, "You used all your voting power");
            vote_.voters[msg.sender][optionId].weight += weight;
            uint256 votePower = balance * weight / 10000;
            vote_.voters[msg.sender][optionId].votedPower += votePower;
            vote_.voteOptions[optionId].votedPower += votePower;
            emit CastVote(voteId, msg.sender, optionId, weight, votePower);
        }        
    }

    function closeVote(uint256 voteId, string memory memo) public {
        require(msg.sender == _deputy, "only deputy can do this");
        require(_voteLists[voteId].snapshotBlock > 0, "vote not exist");
        _voteLists[voteId].open = false;
        emit CloseVote(voteId, msg.sender, memo);
    }

    function getVoteInfo(uint256 voteId) public view 
        returns(
            bool open,
            uint64 startTime,
            uint64 endTime,
            string memory title,
            string memory description,
            uint64 snapshotBlock,
            uint256 votingPower,
            VoteOption[] memory voteOptions
        )
    {
        Vote storage vote_ = _voteLists[voteId];
        open = vote_.open;
        startTime = vote_.startTime;
        endTime = vote_.endTime;
        title = vote_.title;
        description = vote_.description;
        snapshotBlock = vote_.snapshotBlock;
        votingPower = vote_.votingPower;
        voteOptions = vote_.voteOptions;
    }

    function getVoterWeights(uint256 voteId, address voter) public view returns(VoteWeight[] memory voteWeights){
        Vote storage vote_ = _voteLists[voteId];
        uint64 optionCount = vote_.voteOptions.length.toUint64();
        voteWeights = new VoteWeight[](optionCount);
        for(uint64 i = 0; i < optionCount; i++){
            voteWeights[i] = VoteWeight(vote_.voters[voter][i].weight, vote_.voters[voter][i].votedPower);
        }
    }
 
    function setDeputy(address deputy) public onlyOwner{
        _deputy = deputy;
    }
    
    function transfer_ownership(address newOwner_) public onlyOwner{
        transferOwnership(newOwner_);
    }
}