// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Constants.sol";

library Helpers {
    /**
     * A helper function to hash station name
     * @param name {string}
     */
    function _hashName(string calldata name) internal pure returns (bytes32) {
        return keccak256(bytes(name));
    }

    /**
     * A helper function to check if a given name is unique
     * @param name {string} - a name
     */
    function _requireNameUnique(
        string calldata name,
        mapping(bytes32 => uint256) storage _hashedNameToTokenId
    ) internal view {
        require(
            _hashedNameToTokenId[_hashName(name)] == 0,
            "This name is taken"
        );
    }

    /**
     * A helper function to check if a given name is vaild
     * @param name {string} - a name
     */
    function _nameFormatValid(
        string calldata name
    ) internal pure returns (bool) {
        bytes memory bytesName = bytes(name);

        // Check the length
        require(
            bytesName.length >= Constants.MIN_NAME_LENGTH &&
                bytesName.length <= Constants.MAX_NAME_LENGTH,
            "Name length is invalid"
        );

        // Check if the given name contains invalid characters (Capital letters, spcecial characters).
        for (uint256 i = 0; i < bytesName.length; ) {
            if (
                (bytesName[i] < "0" ||
                    bytesName[i] > "z" ||
                    (bytesName[i] > "9" && bytesName[i] < "a")) &&
                bytesName[i] != "." &&
                bytesName[i] != "-" &&
                bytesName[i] != "_"
            ) revert("Capital letters and special characters not allowed");
            unchecked {
                i++;
            }
        }

        return true;
    }

    function _requireNameFormatValid(string calldata name) internal pure {
        require(_nameFormatValid(name), "");
    }
}
