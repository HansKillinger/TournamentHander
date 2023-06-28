// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Moderator is Ownable {
    uint256 moderatorCount = 0;
    mapping(address => bool) private moderators;

    function isModerator(address addr)
        public
        view
        returns (bool)
        {
            if(addr == owner() || moderators[addr] == true){
                return true;
            }
            return false;
        }
    function addModerator(address addr)
        public
        onlyOwner
        {
            moderators[addr] = true;
            moderatorCount += 1;
        }
    function removeModerator(address addr)
        public
        onlyOwner
        {
            moderators[addr] = false;
            moderatorCount -= 1;
        }
    
    modifier onlyMod() {
        isModerator(msg.sender);
        _;
    }
}