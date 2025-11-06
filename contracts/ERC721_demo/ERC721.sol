// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ERC721Demo {
    // tokenId -> 所有者地址
    mapping (uint256 => address) private _tokenOwner;

    // 地址 -> 持有NFT数量
    mapping (address => uint256) private _ownerTokensNFT;

    // tokenId -> 授权地址
    mapping (uint256 => address) private _tokenApproval;

    // 所有者地址 -> 操作员地址 -> 是否授权
    mapping (address => mapping (address => bool)) private _operatorApproval;

    // NFT名称
    string private _name;

    // NFT符号
    string private _symbol;

    // tokenId -> 元数据URI
    mapping (uint256 => string) private _tokenURI;

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // 授权事件: 所有者授权 operator 操作 tokenId
    event Approval(address indexed owner, address indexed operator, uint256 indexed tokenId);

    // 批量授权: 所有者授权 operator 操作所有NFT
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev 初始化NFT名称和符号
     */
     constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
     }

     /**
      * @dev 查询地址持有NFT数量
      * @param owner 目标地址
      * @return 持有数量
      */
      function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721 balance query for zero address");
        return _ownerTokensNFT[owner];
      }

      /**
       * @dev 查询tokenId的持有者
       * @param 持有者地址
       */
       function ownerOf(uint256 tokenId) public view returns(address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "owner address zero");
        return owner;
       }

       /**
        * @dev 授权 operator 指定 tokenId
        * @param to 授权地址
        * @param tokenId NFT ID
        */
        function approve(address to, uint256 tokenId) public {
            address owner = ownerOf(tokenId);
            require(to != owner, "aproval to current owner");
            require(msg.sender == owner || isApprovalForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");
            _tokenApproval[tokenId] = to;
            emit Approval(owner, to, tokenId);
        }

        /**
         * @dev 批量授权/批量撤销 operator 操作所有NFT
         * @param operator 操作员地址
         * @param approved 是否授权
         */
         function setApprovalForAll(address operator, bool approved) public {
            require(msg.sender != operator, "ERC721 approve to called");
            _operatorApproval[msg.sender][operator] = approved;
            emit ApprovalForAll(msg.sender, operator, approved);
         }

         /**
          * @dev 获取tokenId的授权地址
          * @param tokenId NFT ID
          * @return 授权地址
          */
          function getApproved(uint256 tokenId) public view returns (address) {
            require(_exists(tokenId), "ERC721 toknId not exists");
            return _tokenApproval[tokenId];
          }

        /**
         * @dev 检查 operator 是否被owner 批量授权
         * @param owner 所有者地址
         * @param operator 操作者地址
         * @return 是否授权
         */
         function isApprovalForAll(address owner, address operator) public view returns (bool) {
            return _operatorApproval[owner][operator];
         }

         /**
          * @dev 转账NFT
          * @param from 输出地址
          * @param to 转入地址
          * @param tokenId NTF ID
          */
          function transferFrom(address from, address to, uint256 tokenId) public {
            require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner ");
            require(ownerOf(tokenId) == from, "ERC721 transfer from incorrect owner");
            require(to != address(0), "ERC721 transfer to zero address");
            // 清除授权
            _approve(address(0), tokenId);
            _transfer(from, to, tokenId);
          }

          /**
           * @dev 安全转账
           * @param from 转出地址
           * @param to 转入地址
           * @param tokenId NFT ID
           */
           function safeTransferFrom(address from, address to, uint256 tokenId) public {
            safeTransferFrom(from, to, tokenId, "");
           }

           /**
            * @dev 安全转账NFT（带数据参数）
            * @param from 转出地址
            * @param to 转入地址
            * @param tokenId NFT ID
            * @param data 数据
            */
            function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
              require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
              _safeTransfer(from, to, tokenId, data);
            }


            /**
             * @dev 获取NFT名称
             */
             function name() public view returns (string memory) {
              return _name;
             }

             
            /**
             * @dev 获取NFT符号
             */
             function symbol() public view returns (string memory) {
              return _symbol;
             }

          /**
             * @dev 获取NFT元数据URI
             */
             function tokenURI(uint256 tokenId) public view returns (string memory) {
              require(_exists(tokenId), "ERC721: URI not exist");
              return _tokenURI[tokenId];
             }

         /**
          * @dev 检查 tokenId 是否存在
          */
          function _exists(uint256 tokenId) internal view returns(bool) {
            return _tokenOwner[tokenId] != address(0);
          }


          /**
           * @dev 检查该调用者是否是所有者或者是否被授权
           */
           function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
            require(_exists(tokenId), "ERC721 operator on not exists token");
            address owner = ownerOf(tokenId);
            return (spender == owner || isApprovalForAll(owner, spender) || getApproved(tokenId) == spender);
           }


           /**
            * @dev 转账逻辑封装
            */
            function _transfer(address from, address to, uint256 tokenId) internal {
                _ownerTokensNFT[from] -= 1;
                _ownerTokensNFT[to] += 1;
                _tokenOwner[tokenId] = to;

                emit Transfer(from, to, tokenId);
            }

            /**
             * @dev 安全转账（检查合约持有者）
             */
             function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
                _transfer(from, to, tokenId);
                // 若接收地址是合约，必须确认接收
                require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non-ERC721Receiver implementer");
             }

             /**
              * @dev 检查合约接收者是否实现 onERC721Received
              */
              function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
                // 普通地址直接返回true
                if (to.code.length == 0) {
                    return true;
                }

                // 调用合约的onERC721Received函数，校验返回值是否为标准标识
                bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
                return retval == IERC721Receiver(to).onERC721Received.selector;
              }

              /**
               * @dev 内部授权逻辑
               */
               function _approve(address to, uint256 tokenId) internal {
                _tokenApproval[tokenId] = to;
               }

               /**
                * @dev 铸造NFT内部封装
                * @param to 内部接收地址
                * @param tokenId NFT ID
                * @param uri 元数据
                */
                function _mint(address to, uint256 tokenId, string memory uri) internal {
                    require(to != address(0), "ERC721 mint to zero address");
                    require(!_exists(tokenId), "ERC721 token already minted");
                    // 记录所有权
                    _tokenOwner[tokenId] = to;
                    _ownerTokensNFT[to] += 1;
                    // 存储元数据
                    _tokenURI[tokenId] = uri;

                    emit Transfer(address(0), to, tokenId);
                }

              /**
                * @dev 销毁NFT内部封装
                * @param tokenId NFTID
                */
                function _burn(uint256 tokenId) internal  {
                  address owner = ownerOf(tokenId);
                  
                  // 清楚授权
                  _approve(address(0), tokenId);

                  // 更新存储
                  _ownerTokensNFT[owner] -= 1;
                  _tokenOwner[tokenId] = address(0);
                  // 清空元数据
                  delete _tokenURI[tokenId];

                  emit Transfer(owner, address(0), tokenId);
                }

                /**
                 * @dev 公开铸造 NFT
                 * @param to 接收地址
                 * @param tokenId NFT ID
                 * @param uri 元数据 URI
                 */
                 function mint(address to, uint256 tokenId, string memory uri) public {
                  // 控制权限，仅部署者可铸造
                  require(msg.sender == tx.origin && msg.sender == _deployer(), "ERC721: only deployer can mint");
                  _mint(to, tokenId, uri);
                 }


                /**
                 * @dev 销毁NFT（仅NFT所有者可调用）
                 * @param tokenId NFTID
                 */
                function burn(uint256 tokenId) public {
                    require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: burn caller is not owner nor approved");
                    _burn(tokenId);
                }
                

                
                 /**
                  * @dev 获取合约部署者
                  */
                 function _deployer() internal  view  returns(address) {
                  address deployer;
                  assembly {
                    deployer := origin()
                  }
                  return deployer;
                 }



}

interface IERC721Receiver {
    /**
     * @dev 合约接收NFT调用该函数
     * @return 标准返回值
     */
     function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data) external returns(bytes4);
}