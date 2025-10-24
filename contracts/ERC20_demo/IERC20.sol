// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * ERC2O接口合约
 */
 interface IERC2O {
    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool) ;
 }