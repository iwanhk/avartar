// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC998.sol";
import "./Base64.sol";

library ComponentSVG {
    using Strings for uint256;

    function unpack(uint256 _size) internal pure returns (bytes memory) {
        uint256 _y = _size & 0xffffffff; // 64 bit
        uint256 _x = (_size >> 64) & 0xffffffff;
        uint256 _height = (_size >> 128) & 0xffffffff;
        uint256 _width = (_size >> 192) & 0xffffffff;

        return
            abi.encodePacked(
                '<svg width="',
                _width.toString(),
                '" height="',
                _height.toString(),
                '" viewBox="-',
                _x.toString(),
                " -",
                _y.toString(),
                " ",
                _width.toString(),
                " ",
                _height.toString(),
                '"  xml:space="preserve" xmlns="http://www.w3.org/2000/svg">'
            );
    }
}

interface IDataTemplate {
    function get(string calldata _key) external pure returns (string memory);
}

interface IcomponentNFT {
    function component(uint256 tokenId)
        external
        view
        returns (string memory, string memory);

    function setSize(uint256 tokenId, uint256 _size) external;
}

contract componentNFT is ERC721A, Ownable {
    using Strings for uint256;
    using ComponentSVG for uint256;

    IDataTemplate dp;
    uint256[] size;
    string[] keys;

    constructor(address _template) ERC721A("component.NFT", "ATC") {
        dp = IDataTemplate(_template);
    }

    function mint(uint256 _size, string calldata _key)
        external
        returns (uint256)
    {
        require(bytes(dp.get(_key)).length > 0, "key does not exists");
        size.push(_size);
        keys.push(_key);
        _safeMint(msg.sender, 1);
        return totalSupply() - 1;
    }

    function setSize(uint256 tokenId, uint256 _size) external {
        require(ownerOf(tokenId) == msg.sender, "Only Owner");
        size[tokenId] = _size;
    }

    function component(uint256 tokenId)
        external
        view
        returns (string memory, string memory)
    {
        return (
            keys[tokenId],
            string(
                abi.encodePacked(size[tokenId].unpack(), dp.get(keys[tokenId]))
            )
        );
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Nonexistent token");

        uint256 _size = size[tokenId];
        bytes memory _svg = bytes(dp.get(keys[tokenId]));

        _svg = abi.encodePacked(ComponentSVG.unpack(_size), _svg);

        bytes memory content = abi.encodePacked(
            '{"name": "AVATAR", "description": "AVATAR UGC system"',
            ', "image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(abi.encodePacked(_svg)),
            '", "designer": "LUCA355"}'
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

contract avatarNFT is ERC998 {
    using Strings for uint256;
    using ComponentSVG for uint256;

    IcomponentNFT component;

    uint256[] size;

    constructor(address _contract) ERC721A("avatar.NFT", "AVT") {
        component = IcomponentNFT(_contract);
    }

    function mint(uint256 _mainSize, uint256[] calldata _ids) external payable {
        uint256 _id = size.length;
        _safeMint(msg.sender, 1);
        for (uint256 i = 0; i < _ids.length; i++) {
            dockAsset(_id, address(component), _ids[i]);
        }
        size.push(_mainSize);
    }

    function mint(
        uint256 _mainSize,
        uint256[] calldata _ids,
        uint256[] calldata _size
    ) external payable {
        uint256 _id = size.length;
        _safeMint(msg.sender, 1);
        for (uint256 i = 0; i < _ids.length; i++) {
            component.setSize(_ids[i], _size[i]);
            dockAsset(_id, address(component), _ids[i]);
        }
        size.push(_mainSize);
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
            '{"name": "AVATAR", "description": "AVATAR UGC system"',
            ', "image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(
                abi.encodePacked(
                    size[tokenId].unpack(),
                    tokenChildrenSVG(tokenId),
                    "</svg>"
                )
            ),
            '", "designer": "LUCA355.xyz", "attributes": [',
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

    function tokenChildrenSVG(uint256 tokenId)
        internal
        view
        returns (bytes memory)
    {
        bytes memory content = "";
        uint256 length = childrenContracts.length;
        uint256 i;

        for (i = 0; i < length; ++i) {
            address _contract = childrenContracts[i];

            if (dockAssets[_contract] == 0) {
                continue;
            }
            bytes memory _symbol = bytes(IERC721Metadata(_contract).symbol());
            if (
                !(_symbol.length == 3 &&
                    _symbol[0] == "A" &&
                    _symbol[1] == "T" &&
                    _symbol[2] == "C")
            ) {
                continue;
            }

            IcomponentNFT _component = IcomponentNFT(_contract);
            uint256[] memory _ids = children721[tokenId][_contract];

            for (i = 0; i < _ids.length; i++) {
                // Fount Compoment child

                (, string memory _svg) = _component.component(_ids[i]);

                content = abi.encodePacked(content, _svg);
            }
        }

        return content;
    }

    function tokenChildrenURI(uint256 tokenId)
        internal
        view
        override
        returns (bytes memory)
    {
        bytes memory content = "";
        uint256 length = childrenContracts.length;

        for (uint256 i = 0; i < length; ++i) {
            address _contract = childrenContracts[i];

            if (dockAssets[_contract] == 0) {
                continue;
            }
            bytes memory _symbol = bytes(IERC721Metadata(_contract).symbol());
            if (
                !(_symbol.length == 3 &&
                    _symbol[0] == "A" &&
                    _symbol[1] == "T" &&
                    _symbol[2] == "C")
            ) {
                continue;
            }

            IcomponentNFT _component = IcomponentNFT(_contract);
            uint256[] memory _ids = children721[tokenId][_contract];

            for (i = 0; i < _ids.length; i++) {
                // Fount Compoment child

                (string memory _key, ) = _component.component(_ids[i]);

                content = abi.encodePacked(
                    content,
                    '{"trait_type": "ERC721 Component", "value": "',
                    _key,
                    '"},'
                );
            }
            if (_ids.length > 0) {
                // remove the last ','
                assembly {
                    mstore(content, sub(mload(content), 1))
                }
            }
        }

        return content;
    }
}
