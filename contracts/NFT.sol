// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/* 
*/
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "./Base64.sol";

interface IAvatarTemplate{
    function getNo(uint256 id) external pure returns (string memory);
}

contract avatarNFT is Ownable, ERC721A {
    uint256[] ids;
    IAvatarTemplate tp;

    uint256 public Rate = 1;

    constructor(address _template) ERC721A("iColors.NFT", "ICO") {
        tp = IAvatarTemplate(_template);
    }

    function mint(uint256 _id) external payable {
        ids.push(_id);
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

        bytes memory content= abi.encodePacked(
            '{"name": "AVATAR", "description": "SVG AVATAR"',
            ', "image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512" xml:space="preserve">',
                    tp.getNo(ids[tokenId]),
                    '</svg>')),
            '", "designer": "LUCA355", "attributes": ['
        );
        
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(string(abi.encodePacked(content))))
                )
            );
    }
}
