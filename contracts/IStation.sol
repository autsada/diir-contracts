// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IStation {
    /**
     * An external function to mint a station nft.
     * @param to - an address to mint to.
     * @param name - a station name.
     * @param uri - a uri points to the additional info of the nft, this typically is an ipfs cid that points to a json object file.
     For DiiR app, we will store a name, a description, and an endpoint url that can be used to query a station data:
     ===================
        {
            "name": <station name>,
            "description": "The metadata of <station>",
            "properties": {
                uri: "<https://api.com>/<database_station_id>"
            }
        }
     ===================
     */
    function mint(
        address to,
        string calldata name,
        string calldata uri
    ) external;

    /**
     * An external function to validate name - validate length, special characters and uniqueness.
     * @param name - a name of the station
     * @return valid {bool} - if true the given name is valid
     */
    function validateName(
        string calldata name
    ) external view returns (bool valid);

    /**
     * @param name {string} - a station name
     */
    function stationOwner(string calldata name) external view returns (address);
}
