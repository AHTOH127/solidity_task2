// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeggingContract {

    // 捐赠事件
    event Donation(address _address, uint256 _amount); 

    address private immutable owner;

    // 记录
    mapping (address => uint256) public record;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // 捐赠功能
    function donate() external payable {
        require(msg.value > 0, "donation value > 0");
        record[msg.sender] += msg.value;

        // 释放事件
        emit Donation(msg.sender, msg.value);
    }

    // 取款功能
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "balance > 0");
        
        payable (owner).transfer(balance);
    }

    // 查询余额
    function getDonation(address _address) external view returns(uint256) {
        return record[_address];
    }
}