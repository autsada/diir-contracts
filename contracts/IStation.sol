// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IStation {
    /**
     * An external function to mint a station nft.
     * @param to - an address to mint to.
     * @param name - a station name.
     */
    function mint(address to, string calldata name) external;

    /**
     * An external function to validate name - validate length, special characters and uniqueness.
     * @param name - a name of the station
     * @return valid {bool} - if true the given name is valid
     */
    function validateName(
        string calldata name
    ) external view returns (bool valid);

    /**
     * A withdraw funds function for contract owner.
     * @dev Make sure to add `onlyRole(DEFAULT_ADMIN_ROLE` in the implementation function.
     * @param to {address} - an address to transfer to
     */
    function withdraw(address to) external;

    /**
     * A function to send tips
     */
    function tip(string calldata name, uint256 qty) external payable;

    /**
     * A public function to calculate tips.
     */
    function calculateTips(uint256 qty) external view returns (uint256);
}
