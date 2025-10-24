// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {IERC2O} from "./IERC20.sol";

contract ERC20 is IERC2O {
    // 账户代币
    mapping(address => uint256) public override  balanceOf;

    // 授权额度
    mapping(address => mapping (address => uint256)) public override  allowance;

    // 代币总数
    uint256 public override totalSupply; 

    // 名称
    string public name;

    // 符号
    string public symbol;

    // 小数位数
    uint8 public decimals = 18;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /**
     * @dev 发送代币
     * @param to 接收地址
     * @param value 发送数量
     */
    function transfer(address to, uint value) public override returns (bool) {
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev 代币授权
     * @param spander 授权地址
     * @param value 数量
     */
    function approve(address spander, uint value) public override returns (bool) {
        allowance[msg.sender][spander] = value;
        emit Approval(msg.sender, spander, value);
        return true;
    }

    
     /**
     * @dev 授权转账
     * @param from 发送地址
     * @param to 接收地址
     * @param value 转账额度
     */   
    function transferFrom(address from, address to, uint value) public override returns (bool) {
        allowance[from][msg.sender] -= value;
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
    
    /**
     * @dev 铸造代币
     * @param value 铸造数量
     */
    function mint(uint value) external {
        balanceOf[msg.sender] += value;
        totalSupply += value;
        emit Transfer(address(0), msg.sender, value);
    }

     /**
     * @dev 销毁代币
     * @param value 铸造数量
     */
    function burn(uint value) external {
        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Transfer(msg.sender, address(0), value);
    }

}