// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


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

contract Jackpot {
    /**
     * @dev Write to log info about the new game.
     *
     * @param _game Game number.
     * @param _time Time when game stated.
     
     */
    event Game(uint _game, uint indexed _time);

    struct Bet {
        address addr;
        uint256 ticketstart;
        uint256 ticketend;
    }
    struct StakingInfo {
        uint depositTime;
        uint balance;
    }

    mapping(uint256 => mapping(uint256 => Bet)) public bets;
    mapping(address => StakingInfo) public stakeInfo;
    mapping(uint256 => uint256) public totalBets;

    //winning tickets history
    mapping(uint256 => uint256) public ticketHistory;

    //winning address history
    mapping(uint256 => address) public winnerHistory;

    IERC20 public token;

    // Game fee.
    uint8 public fee = 10;
    // Current game number.
    uint public game;
    // Min eth deposit jackpot
    uint public constant minethjoin = 10000 * 10 ** 18;

    // Game status
    // 0 = running
    // 1 = stop to show winners animation

    uint public gamestatus = 0;

    // All-time game jackpot.
    uint public allTimeJackpot = 0;
    // All-time game players count
    uint public allTimePlayers = 0;

    // The array of all games
    uint[] public games;

    // Store game jackpot.
    mapping(uint => uint) jackpot;
    // Store game players.
    mapping(uint => address[]) players;
    // Store total tickets for each game
    mapping(uint => uint) tickets;
    // Store game start block number.
    mapping(uint => uint) gamestartblock;

    address payable public owner;
    address payable taxWallet;

    uint counter = 1;

    /**
     * @dev Check sender address and compare it to an owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    /**
     * @dev Initialize game.
     * @dev Create ownable and stats aggregator instances,
     * @dev set funds distributor contract address.
     *
     */

    constructor() {
        owner = payable(msg.sender);
        startGame();
    }

    /**
     * @dev The method that allows buying tickets by directly sending ether to the contract.
     */

    function setToken(address _address) external {
        require(address(token) == address(0));
        token = IERC20(_address);
    }


    function playerticketstart(
        uint _gameid,
        uint _pid
    ) public view returns (uint256) {
        return bets[_gameid][_pid].ticketstart;
    }

    function playerticketend(
        uint _gameid,
        uint _pid
    ) public view returns (uint256) {
        return bets[_gameid][_pid].ticketend;
    }

    function totaltickets(uint _uint) public view returns (uint256) {
        return tickets[_uint];
    }

    function playeraddr(uint _gameid, uint _pid) public view returns (address) {
        return bets[_gameid][_pid].addr;
    }

    /**
     * @dev Returns current game players.
     */
    function getPlayedGamePlayers() public view returns (uint) {
        return getPlayersInGame(game);
    }

    /**
     * @dev Get players by game.
     *
     * @param playedGame Game number.
     */
    function getPlayersInGame(uint playedGame) public view returns (uint) {
        return players[playedGame].length;
    }

    /**
     * @dev Returns current game jackpot.
     */
    function getPlayedGameJackpot() public view returns (uint) {
        return getGameJackpot(game);
    }

    /**
     * @dev Get jackpot by game number.
     *
     * @param playedGame The number of the played game.
     */
    function getGameJackpot(uint playedGame) public view returns (uint) {
        return jackpot[playedGame];
    }


    /**
     * @dev Get game start block by game number.
     *
     * @param playedGame The number of the played game.
     */
    function getGamestartblock(uint playedGame) public view returns (uint) {
        return gamestartblock[playedGame];
    }

    /**
     * @dev Get total ticket for game
     */
    function getGameTotalTickets(uint playedGame) public view returns (uint) {
        return tickets[playedGame];
    }

    /**
     * @dev Start the new game.
     */
    function start() public onlyOwner {
        if (players[game].length > 0) {
            pickTheWinner();
        }
        startGame();
    }

    /**
     * @dev Start the new game.
     */
    function setGamestatusZero() public onlyOwner {
        gamestatus = 0;
    }

    /**
     * @dev Get random number. It cant be influenced by anyone
     * @dev Random number calculation depends on block timestamp,
     * @dev difficulty, counter and jackpot players length.
     *
     */
    function randomNumber(uint number) internal returns (uint) {
        counter++;
        uint random = uint(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    counter,
                    players[game].length,
                    gasleft()
                )
            )
        ) % number;
        return random + 1;
    }

    /**
     * @dev adds the player to the jackpot game.
     */

    function deposit(address from, uint amount) public {
        require(
            msg.sender == address(token),
            "Stake by sending to token contract"
        );
        require(gamestatus == 0);
        require(amount >= 0, "Amount must be greater than zero");

        stakeInfo[from].depositTime = block.timestamp;
        stakeInfo[from].balance += amount;

        uint newtotalstr = totalBets[game];
        bets[game][newtotalstr].addr = address(from);
        bets[game][newtotalstr].ticketstart = tickets[game] + 1;
        bets[game][newtotalstr].ticketend =
            ((tickets[game] + 1) + (amount / (10000 * 10 ** 18))) -
            1;

        totalBets[game] += 1;
        jackpot[game] += amount;
        tickets[game] += (amount / (10000 * 10 ** 18));

        players[game].push(from);
    }

    /**
     * @dev Withdraw token
     */
    function withdraw() public {
        require(stakeInfo[msg.sender].balance > 0, "Your balance is zero");
        require(
            block.timestamp > stakeInfo[msg.sender].depositTime + 1 days,
            "Withdraw is not available"
        );
        token.transfer(msg.sender, stakeInfo[msg.sender].balance);
        stakeInfo[msg.sender].balance = 0;
    }

    /**
     * @dev Start the new game.
     * @dev Checks game status changes, if exists request for changing game status game status
     * @dev will be changed.
     */
    function startGame() internal {
        game += 1;
        gamestartblock[game] = block.timestamp;
        emit Game(game, block.timestamp);
    }

    /**
     * @dev Pick the winner using random number provably fair function.
     */
    function pickTheWinner() internal {
        uint winner;
        uint toPlayer = address(this).balance > 1 ether ? 1 ether : address(this).balance;
        if (players[game].length == 1) {
            payable(players[game][0]).transfer(toPlayer);
            winner = 0;
            ticketHistory[game] = 1;
            winnerHistory[game] = players[game][0];
        } else {
            winner = randomNumber(tickets[game]); //winning ticket
            uint256 lookingforticket = winner;
            address ticketwinner;
            for (uint8 i = 0; i <= totalBets[game]; i++) {
                address addr = bets[game][i].addr;
                uint256 ticketstart = bets[game][i].ticketstart;
                uint256 ticketend = bets[game][i].ticketend;
                if (
                    lookingforticket >= ticketstart &&
                    lookingforticket <= ticketend
                ) {
                    ticketwinner = addr; //finding winner address
                }
            }

            ticketHistory[game] = lookingforticket;
            winnerHistory[game] = ticketwinner;

            payable(ticketwinner).transfer(toPlayer); //send prize to winner
        }

        allTimeJackpot += toPlayer;
        allTimePlayers += players[game].length;
    }

    receive() external payable {}

    fallback() external payable {}
}