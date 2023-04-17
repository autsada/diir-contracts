// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./ITip.sol";
import "./IStation.sol";

/**
 * @title DiiR ERC20 Token
 * @author Autsada T
 *
 * @notice The Tokens are non-burnable/non-transferable.
 */

contract DiiRTip is
    Initializable,
    ERC20Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ITip
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // Chainlink ETH/USD price feed contract address for use to calculate tips.
    AggregatorV3Interface internal priceFeed;

    // The percentage to be deducted from the tips (as a commission to the contract owner) before transfering the tips to the receiver, need to store it as a whole number and do division when using it.
    uint256 public rate;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @param priceFeedAddress - An address of ChainLink price feed contract
     */
    function initialize(address priceFeedAddress) public initializer {
        __ERC20_init("DiiR Tip ERC20 Token", "DiiRT");
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        rate = 10;
    }

    /**
     * @inheritdoc ITip
     */
    function withdraw(
        address to
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(to).transfer(address(this).balance);
    }

    /**
     * @inheritdoc ITip
     */
    function mint(address to, uint256 qty) external payable override {
        uint tips = msg.value;

        // Validate tips
        bool isValid = _tipsValid(tips, qty);
        require(isValid, "Invalid values");

        uint256 fee = (tips * rate) / 100;
        uint256 net = tips - fee;

        // Transfer net to receiver.
        payable(to).transfer(net);

        // mint a CTBT to the caller
        _mint(msg.sender, qty * decimals());
    }

    /**
     * @inheritdoc ITip
     */
    function calculateTips(uint256 qty) public view override returns (uint256) {
        return _usdToWei() * qty;
    }

    /**
     * A private function to validate if the tips valid.
     * Accept maximum 10% different between the submitted tips and the calculated tips.
     */
    function _tipsValid(uint256 tips, uint256 qty) private view returns (bool) {
        uint256 amount = calculateTips(qty);
        uint256 multiplier = 100;
        uint256 diff = (tips * multiplier) / amount;

        return
            tips >= amount ? diff - multiplier <= 10 : multiplier - diff <= 10;
    }

    /**
     * A private function to calculate 1 USD in Wei.
     */
    function _usdToWei() private view returns (uint256) {
        (int256 price, uint8 decimals) = _getEthPrice();

        // Calculate 1 usd in wei.
        return (1e18 * (10 ** uint256(decimals))) / uint256(price);
    }

    /**
     * A private function to get ETH price in USD from Chainlink.
     * @dev the returned value is a usd amount with decimals and the decimals, for exmaple if the returned value is (118735000000, 8) it means 1 eth = 1187.35000000 usd.
     */
    function _getEthPrice() private view returns (int, uint8) {
        // Get ETH/USD price from Chainlink price feed.
        (, int price, , , ) = priceFeed.latestRoundData();

        return (price, priceFeed.decimals());
    }

    /**
     * @notice If it's not the first creation, the token is non-transferable.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable) {
        require(from == address(0) && to != address(0), "Non transferable");
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}
}
