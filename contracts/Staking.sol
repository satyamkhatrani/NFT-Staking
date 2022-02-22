// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./BTCToken.sol";
import "./BitcoinERC1155.sol";

contract Staking {
    address public tokenContract;
    address public nftContract;
    address public owner;

    constructor(address _tokenContract, address _nftContract) {
        tokenContract = _tokenContract;
        nftContract = _nftContract;
        owner = msg.sender;
    }

    struct stakeInfo {
        uint256 tokenId;
        uint256 price;
        uint256 releaseTime;
        uint256 stakingReward;
    }

    enum TimeSlot {
        oneMonth,
        sixMonth,
        oneYear
    }

    mapping(address => stakeInfo) public Stakes;
    mapping(address => bool) public isStaker;

    function stake(
        uint256 _tokenId,
        uint256 _price,
        uint256 _timeSlot
    ) public {
        require(
            uint256(0) <= _timeSlot || uint256(3) > _timeSlot,
            "please enter correct timeslot"
        );
        uint256 _releaseTime;
        uint256 _stakingReward;
        if (uint256(TimeSlot.oneMonth) == _timeSlot) {
            _releaseTime = block.timestamp + 4 weeks;
            _stakingReward = (_price * 5) / 100;
        } else if (uint256(TimeSlot.sixMonth) == _timeSlot) {
            _releaseTime = block.timestamp + 16 weeks;
            _stakingReward = (_price * 10) / 100;
        } else if (uint256(TimeSlot.oneYear) == _timeSlot) {
            _releaseTime = block.timestamp + 52 weeks;
            _stakingReward = (_price * 15) / 100;
        }

        BitcoinERC1155(nftContract).safeTransferFrom(
            msg.sender,
            owner,
            _tokenId,
            1,
            ""
        );
        Stakes[msg.sender] = stakeInfo(
            _tokenId,
            _price,
            _releaseTime,
            _stakingReward
        );
        isStaker[msg.sender] = true;
    }

    function unstake() public {
        require(isStaker[msg.sender], "You are not contributed in stake");
        require(
            Stakes[msg.sender].releaseTime <= block.timestamp,
            "Your time is not finish yet!!!"
        );
        BitcoinERC1155(nftContract).safeTransferFrom(
            owner,
            msg.sender,
            Stakes[msg.sender].tokenId,
            1,
            ""
        );
        BTCToken(tokenContract).transfer(
            msg.sender,
            Stakes[msg.sender].stakingReward
        );
        isStaker[msg.sender] = false;
    }
}
