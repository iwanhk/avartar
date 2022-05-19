// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC721A.sol";
import "./Base64.sol";

interface IDataTemplate {
    function get(uint256 id) external pure returns (string memory);
}

contract avatarNFT is Ownable, ERC721A, IERC721Receiver {
    struct Docker20 {
        address contractAddress;
        uint256 amount;
    }
    struct Docker721 {
        address contractAddress;
        uint256[] id;
    }

    event Received(address _from, uint256 tokenId);

    uint256[] ids;
    mapping(uint256 => mapping(address => Docker20)) children20;
    mapping(uint256 => mapping(address => Docker721)) children721;

    IDataTemplate dp;

    uint256 public Rate = 1;

    constructor(address _template) ERC721A("avatar.NFT", "AVT") {
        dp = IDataTemplate(_template);
    }

    function dockERC20(
        uint256 tokenId,
        address _contract,
        uint256 _amount
    ) external returns (bool) {
        require(_contract != address(0) && _amount > 0, "Invalid arg");

        IERC20 erc20 = IERC20(_contract);
        if (children20[tokenId][_contract].contractAddress == address(0)) {
            // new record
            children20[tokenId][_contract] = Docker20(_contract, _amount);
        } else {
            // found a record
            children20[tokenId][_contract].amount += _amount;
        }

        return erc20.transferFrom(msg.sender, address(this), _amount);
    }

    function dockERC721(
        uint256 tokenId,
        address _contract,
        uint256 _id
    ) external {
        require(_contract != address(0), "Invalid arg");

        IERC721 erc721 = IERC721(_contract);
        if (children721[tokenId][_contract].contractAddress == address(0)) {
            // new record
            children721[tokenId][_contract] = Docker721(
                _contract,
                new uint256[](0)
            );
        }
        // found a record
        children721[tokenId][_contract].id.push(_id);

        return erc721.transferFrom(msg.sender, address(this), _id);
    }

    function undockERC721(
        uint256 tokenId,
        address _contract,
        uint256 _id,
        address _to
    ) external {
        require(ownerOf(tokenId) == msg.sender, "Not Owner");

        IERC721 erc721 = IERC721(_contract);

        uint256[] memory _ids = children721[tokenId][_contract].id;
        uint256 size = _ids.length;

        for (uint256 i = 0; i < size; i++) {
            if (_ids[i] == _id) {
                erc721.transferFrom(address(this), _to, _id);
                return;
            }
        }

        revert("Id not found");
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

        bytes memory content = abi.encodePacked(
            '{"name": "AVATAR", "description": "SVG AVATAR"',
            ', "image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(
                abi.encodePacked(
                    '<svg xmlns="htdp://www.w3.org/2000/svg" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512" xml:space="preserve">',
                    dp.get(ids[tokenId]),
                    "</svg>"
                )
            ),
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

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external override returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        emit Received(_from, _tokenId);
        return 0x150b7a02;
    }
}
