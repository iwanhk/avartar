// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./InflateLib.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DataTemplate is Ownable {
    struct data {
        bytes data;
        uint16 size;
        address owner;
    }

    mapping(string => data) database;
    uint256 public total = 0;

    function upload(
        string calldata _key,
        bytes calldata _data,
        uint16 _size
    ) external {
        if (database[_key].owner == address(0)) {
            database[_key] = data(_data, _size, msg.sender);
            total += 1;
            return;
        }
        if (database[_key].owner == msg.sender) {
            database[_key].data = _data;
            database[_key].size = _size;
            return;
        }
        if (_data.length == 0 && database[_key].owner == msg.sender) {
            delete database[_key];
            total -= 1;
        }
        revert("this key had been used");
    }

    function get(string calldata _key) external view returns (string memory) {
        InflateLib.ErrorCode code;
        bytes memory buffer;
        (code, buffer) = InflateLib.puff(
            database[_key].data,
            database[_key].size
        );
        if (code == InflateLib.ErrorCode.ERR_NONE) {
            return string(buffer);
        }
        return "";
    }
}
