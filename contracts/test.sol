// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract T20 is ERC20 {
    constructor() ERC20("T20", "T20") {
        _mint(msg.sender, 100 * 10**18);
    }
}

contract T721 is ERC721 {
    constructor() ERC721("T721", "T721") {
        _safeMint(msg.sender, 0);
        _safeMint(msg.sender, 1);
        _safeMint(msg.sender, 2);
    }
}
