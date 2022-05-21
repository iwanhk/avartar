// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./ERC998.sol";
import "./Base64.sol";

interface IDataTemplate {
    function get(uint256 id) external pure returns (string memory);
}

contract avatarNFT is ERC998 {
    using Strings for uint256;

    IDataTemplate dp;

    uint256 public Rate = 1;

    constructor(address _template) ERC721A("avatar.NFT", "AVT") {
        dp = IDataTemplate(_template);
    }

    function mint() external payable {
        _safeMint(msg.sender, 1);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Nonexistent token");

        bytes memory content = abi.encodePacked(
            '{"name": "AVATAR", "description": "SVG AVATAR"',
            ', "image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(
                abi.encodePacked(
                    '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1094" viewBox="0 0 1024 1094" style="enable-background:new 0 0 1024 1094" xml:space="preserve">',
                    dp.get(tokenId),
                    "</svg>"
                )
            ),
            '", "designer": "LUCA355", "attributes": [',
            tokenChildrenURI(tokenId),
            "]}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(string(abi.encodePacked(content))))
                )
            );
    }
}
