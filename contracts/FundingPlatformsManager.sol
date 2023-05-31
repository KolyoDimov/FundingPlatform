// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./FundingPlatformsStorage.sol";

/**
 * @dev Контракт за събиране на средства спряло дадена кампания
 */
contract FundingPlatformsManager is FundingPlatformsStorage {
    // internal variables
    // ------------------------------------

    // Мап с данни за всяко дарение на п
    mapping(address => mapping(uint256 => FundingLibrary.FundingContributor))
        internal contributors;

    // Internal functions
    // ------------------------------------

    /**
     * @notice  Връща събраната сума.
     * @dev     Може да не е цялата.
     * @param   eventIdentifier  Уникален идентификатор на събитието..
     * @return  uint256  Събрана сума.
     */
    function getEventFundings(
        uint256 eventIdentifier
    ) internal view returns (uint256) {
        return fundingPlatforms[eventIdentifier].collectedAmount;
    }

    /**
     * @notice  Проверяваме дали събитието вмомента е активно.
     * @dev     Проверяват се началната и крайната дата.
     * @param   eventIdentifier Уникален идентификатор на събитието.
     */
    function _isPlatformOpenForDonations(
        uint256 eventIdentifier
    ) internal view {
        uint time = block.timestamp;
        require(
            fundingPlatforms[eventIdentifier].eventStartTimestamp < time,
            "The funding not open yet."
        );
        require(
            time < fundingPlatforms[eventIdentifier].eventEndTimestamp,
            "The funding has closed."
        );
    }

    /**
     * @notice  Функция с която отчитаме събраните средства.
     * @dev     Добавяме средствата, като може да минем.
     * @param   eventIdentifier Уникален идентификатор на събитието.
     * @param   amount Средства който ще се дарят.
     */
    function _accountEventFund(
        uint256 eventIdentifier,
        uint256 amount
    ) internal {
        FundingLibrary.FundingContributor storage contributor = contributors[
            msg.sender
        ][eventIdentifier];

        unchecked {
            fundingPlatforms[eventIdentifier].collectedAmount += amount;
            contributor.funds += amount;
        }
    }

    /**
     * @notice  Функция с която отчитаме събраните средства.
     * @dev     Добавяме средствата, като може да минем.
     * @param   eventIdentifier Уникален идентификатор на събитието.
     * @param   amount Средства който ще се дарят.
     */
    function _accountEventRefund(
        uint256 eventIdentifier,
        uint256 amount
    ) internal {
        FundingLibrary.FundingContributor storage contributor = contributors[
            msg.sender
        ][eventIdentifier];

        unchecked {
            fundingPlatforms[eventIdentifier].collectedAmount -= amount;
            contributor.funds -= amount;
        }
    }

    /**
     * @notice  Функция която проверява дали сумата за даряване е позволена.
     * @dev     .
     * @param   eventIdentifier Уникален идентификатор на събитието..
     * @param   amount Средства който ще се дарят.
     */
    function _isFundingAmountAllowed(
        uint256 eventIdentifier,
        uint256 amount
    ) internal view {
        require(
            fundingPlatforms[eventIdentifier].fundingGoal >= amount,
            "To much"
        );
    }

    /**
     * @notice  .
     * @dev     .
     * @param   eventIdentifier  .
     * @param   amount  .
     */
    function _isRefundAmountApproved(
        uint256 eventIdentifier,
        uint256 amount
    ) internal view {
        require(
            contributors[msg.sender][eventIdentifier].funds >= amount,
            "Not enough amount to refund"
        );
    }

    /**
     * @notice  Функция която проверява дали средствата са събрани.
     * @dev     Средствата са събрани само ако
     * @param   eventIdentifier Уникален идентификатор на събитието..
     */
    function _isFundGoalCollected(uint256 eventIdentifier) internal view {
        require(
            fundingPlatforms[eventIdentifier].collectedAmount >=
                fundingPlatforms[eventIdentifier].fundingGoal,
            "The goal is not collected"
        );
    }

    // Modifiers
    // ------------------------------------

    /**
     * @dev Проверяваме дали може да дарим средства
     */
    modifier isFundingAllowed(uint256 eventIdentifier, uint256 amount) {
        _isFundingAmountAllowed(eventIdentifier, amount);
        _isPlatformOpenForDonations(eventIdentifier);
        _;
    }

    /**
     * @dev Поверяваме дали може да изтеглим дарените средства
     */
    modifier isWithdrawAllowed(uint256 eventIdentifier) {
        _isFundGoalCollected(eventIdentifier);
        _;
    }

    /**
     * @dev Поверяваме дали може да изтеглим дарените средства
     */
    modifier isRefundAllowed(uint256 eventIdentifier, uint256 amount) {
        _isRefundAmountApproved(eventIdentifier, amount);
        _;
    }
}
