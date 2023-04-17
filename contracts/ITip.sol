// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ITip {
    /**
     * A withdraw funds function for contract owner.
     * @dev Make sure to add `onlyRole(DEFAULT_ADMIN_ROLE` in the implementation function.
     * @param to {address} - an address to transfer to
     */
    function withdraw(address to) external;

    /**
     * A function to send tips to another address and mint ERC20 token
     * @param to {address} - an address to send the tips to
     * @param qty {uint256} - number of tokens to be minted to the caller in exchange to the tips
     */
    function mint(address to, uint256 qty) external payable;

    /**
     * A public function to calculate tips.
     */
    function calculateTips(uint256 qty) external view returns (uint256);
}
