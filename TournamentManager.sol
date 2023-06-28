// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/Moderator.sol";

contract TournamentHandler is Ownable, Moderator {

    struct winningRewards{
        uint256 firstPlace;
        uint256 secondPlace;
        uint256 thirdPlace;
    }

    struct tourneyWinners{
        address firstPlace;
        address secondPlace;
        address thirdPlace;
        bool paid;
    }


    mapping(uint256 tourneyNumber => winningRewards) public tokenPool;
    mapping(uint256 tourneyNumber => mapping(address addr => bool)) private enrolledPlayers;
    mapping(uint256 tourneyNumber => tourneyWinners) public winners;
    mapping(uint256 tourneyNumber => uint256) private enrollEnd;

    uint256 public currentTourney = 0;
    uint256 public feeBalance = 0;
    uint256 public buyIn = 5 * 10**18;
    uint256 public maintainFee = .5 * 10**18;


    function setBuyIn(uint256 newBuyIn)
        public
        onlyOwner
        {
            buyIn = newBuyIn;
        }


    function setMaintainFee(uint256 newFee)
        public
        onlyOwner
        {
            maintainFee = newFee;
        }


    function enableTournament(uint enrollDays)
        public
        onlyMod
        {
            require(enrollDays > 0, "Cannot be 0");
            require(winners[currentTourney].paid || currentTourney == 0, "Current Tourney Not Paid");
            currentTourney += 1;
            uint256 time = block.timestamp + (enrollDays * 3600);
            enrollEnd[currentTourney] = time;
        }


    function enrollPlayer()
        public payable
        {
            require(msg.value == buyIn, "Incorrect Amount of Funds Sent");
            require(enrollEnd[currentTourney] > block.timestamp, "Tournament Already Started ");
            require(!enrolledPlayers[currentTourney][msg.sender], "Already Enrolled");
            uint256 after_fee = buyIn-maintainFee;
            uint256 first = after_fee / 2;
            uint256 third = first / 4;
            uint256 second = first - third;
            tokenPool[currentTourney].firstPlace += first;
            tokenPool[currentTourney].secondPlace += second;
            tokenPool[currentTourney].thirdPlace += third;
            feeBalance += maintainFee;
            enrolledPlayers[currentTourney][msg.sender] = true;
        }


    function getCurrent()
        public
        view
        returns(uint256 number, uint256 endtime, bool enrolled){
            return (currentTourney, enrollEnd[currentTourney], isEnrolled(msg.sender));
        }


    function isEnrolled(address addr)
        public
        view
        returns(bool)
        {
            return enrolledPlayers[currentTourney][addr];
        }


    function setWinners(address first, address second, address third)
        public
        payable
        onlyMod
        {
            require(!winners[currentTourney].paid, "Already Set and Paid");
            winners[currentTourney] = tourneyWinners(first, second, third, true);
            address payable one = payable(first);
            address payable two = payable(second);
            address payable three = payable(third);
            one.transfer(tokenPool[currentTourney].firstPlace);
            two.transfer(tokenPool[currentTourney].secondPlace);
            three.transfer(tokenPool[currentTourney].thirdPlace);
        }


    function balance()
        public
        view
        returns(uint256)
        {return address(this).balance;}



    function withdrawFees()
        public
        onlyOwner
        {
            address payable to = payable(msg.sender);
            to.transfer(feeBalance);
            feeBalance = 0;
        }

}
