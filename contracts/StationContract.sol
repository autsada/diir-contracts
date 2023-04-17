// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "hardhat/console.sol";

import "./IStation.sol";
import "./Helpers.sol";

/**
 * @title DiiR Station NFT Contract
 * @author Autsada T
 *
 * @notice An address (EOA) can mint as many tokens as they want as long as they provide a unique name and can cover gas fee.
 * @notice The DiiR Station NFTs are non-burnable/non-transferable.
 */

contract DiiRStation is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IStation
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    // Token Ids counter.
    CountersUpgradeable.Counter private _tokenIdCounter;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // Mapping (hash => token id) of hashed name to token id.
    mapping(bytes32 => uint256) private _hashedNameToTokenId;

    // Events
    event StationMinted(
        uint256 indexed tokenId,
        address indexed owner,
        string uri,
        uint256 timestamp
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * Initialize function
     */
    function initialize() public initializer {
        __ERC721_init("DiiR Station NFT", "DiiRS");
        __ERC721URIStorage_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /**
     * @inheritdoc IStation
     */
    function mint(
        address to,
        string calldata name,
        string calldata uri
    ) external override {
        // Validate input data
        _requireStationDataValid(name, uri);

        // Increment the counter before using it so the id will start from 1 (instead of 0).
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        // Mint an nft to the caller.
        _safeMint(to, tokenId);
        // Set tokenURI
        _setTokenURI(tokenId, uri);

        _hashedNameToTokenId[Helpers._hashName(name)] = tokenId;

        // Emit an event.
        emit StationMinted(tokenId, to, uri, block.timestamp);
    }

    /**
     * @inheritdoc IStation
     */
    function validateName(
        string calldata name
    ) external view override returns (bool valid) {
        // Validate the given name length and special characters.
        Helpers._requireNameFormatValid(name);

        // Check if the given name is unique.
        Helpers._requireNameUnique(name, _hashedNameToTokenId);

        valid = true;
    }

    /**
     * @inheritdoc IStation
     */
    function stationOwner(
        string calldata name
    ) external view override returns (address) {
        bytes32 hashedName = Helpers._hashName(name);
        uint256 tokenId = _hashedNameToTokenId[hashedName];

        return ownerOf(tokenId);
    }

    /**
     * A helper function to validate create profile data
     */
    function _requireStationDataValid(
        string calldata name,
        string calldata uri
    ) private view {
        // Validate the given name length and special characters.
        Helpers._requireNameFormatValid(name);

        // Check if the name is unique.
        Helpers._requireNameUnique(name, _hashedNameToTokenId);

        // Validate token uri
        Helpers._requireNotTooShortURI(uri);
        Helpers._requireNotTooLongURI(uri);
    }

    /**
     * Profile tokens are non-transferable.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721Upgradeable) {
        require(from == address(0) && to != address(0), "Non transferable");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.
    function _burn(
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
