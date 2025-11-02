// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ERC20 {
    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件
    event Approve(address indexed ownder, address indexed spender, uint256 value);

    // 账户代币
    mapping(address => uint256) public  _balance;

    // 授权额度
    mapping(address => mapping (address => uint256)) public _allowance;

    // 代币总数
    uint256 public _totalSupply; 

    // 名称
    string public name;

    // 符号
    string public symbol;

    // 小数位数
    uint8 public decimals = 18;

    // 合约所有者
    address public _owner ;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    modifier onlyOwner() {
        address ownder = msg.sender;
        _;
    }
 
    /**
     * @dev 查询账户余额
     * @param account 目标账户地址
     * @return 账户余额
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balance[account];
    }

    /**
     * @dev 转账
     * @param to 接收方地址
     * @param value 转账数量
     */
    function transfer(address to, uint256 value) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner,to, value);
        return true;
    }

    /**
     * @dev 授权
     * @param spender 被授权地址
     * @param value 授权数量
     */
    function approve(address spender, uint256 value) public  returns (bool) {
       address owner = msg.sender;
       _approve(owner, spender, value);
        return true;
    }

    
     /**
     * @dev 授权转账
     * @param from 付款方地址
     * @param to 收款方地址
     * @param value 转账额度
     */   
    function transferFrom(address from, address to, uint value) public  returns (bool) {
        address spender = msg.sender;
        _spenderAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    
    /**
     * @dev 铸造代币
     * @param value 铸造数量
     */
    function mint(address to, uint value) public onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        _balance[to] += value;
        _totalSupply += value;
        emit Transfer(address(0), to, value);
    }

     /**
     * @dev 销毁代币
     * @param to 销毁代币地址
     * @param value 铸造数量
     */
    function burn(address to, uint256 value) public onlyOwner {
        require(to != address(0), "Cannot burn to zero address");
        _totalSupply -= value;
        _balance[to] -= value;
        
        emit Transfer(to, address(0), value);
    }

    /**
     * @dev 内部转账逻辑
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(_balance[from] >= value, "Not enough value");
        _balance[from] -= value;
        _balance[to] += value;
        emit Transfer(from, to, value);
    }

    /**
     * @dev 内部授权逻辑
     */
    function _approve(address owner, address spender, uint256 value) internal   {
        require(owner != address(0), "Approve owner the zero address");
        require(spender != address(0), "Approve spender the zero address");
        _allowance[owner][spender] = value;
        emit Approve(owner, spender, value);
    }


    /**
     * @dev 内部消费额度授权
     */
    function _spenderAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = _allowance[owner][spender];
        if (currentAllowance != type(uint256).max) {// 支持无限授权
             require(currentAllowance >= value, "Allowance exceeded");
            unchecked {
                _approve(owner, spender, currentAllowance - value);
            }
        }
    }

}