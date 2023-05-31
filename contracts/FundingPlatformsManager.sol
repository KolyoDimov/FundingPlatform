// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./FundingPlatformsStorage.sol";

/**
 * @dev Контракт за събиране на средства спряло дадена кампания
 */
contract FundingPlatformsManager is FundingPlatformsStorage {
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
     * @param   fundAmount Средства който ще се дарят.
     */
    function _accountFundToEvent(
        uint256 eventIdentifier,
        uint256 fundAmount
    ) internal {
        unchecked {
            fundingPlatforms[eventIdentifier].collectedAmount += fundAmount;
        }
    }

    /**
     * @notice  Функция която проверява дали сумата за даряване е позволена.
     * @dev     .
     * @param   eventIdentifier Уникален идентификатор на събитието..
     * @param   fundAmount Средства който ще се дарят.
     */
    function _isFundingAmountAllowed(
        uint256 eventIdentifier,
        uint256 fundAmount
    ) internal view {
        require(
            fundingPlatforms[eventIdentifier].fundingGoal >= fundAmount,
            "To much"
        );
    }

    /**
     * @notice  Функция която проверява дали средствата са събрани.
     * @dev     Средствата са събрани само ако
     * @param   eventIdentifier Уникален идентификатор на събитието..
     */
    function _isFundGoalCollected(uint256 eventIdentifier) internal view {
        require(
            fundingPlatforms[eventIdentifier].collectedAmount >= fundingPlatforms[eventIdentifier].fundingGoal,
            "The goal is not collected"
        );
    }

    // Modifiers
    // ------------------------------------

    /**
     * @dev Проверяваме дали може да дарим средства
     */
    modifier isFundingAllowed(uint256 eventIdentifier, uint256 fundAmount) {
        _isFundingAmountAllowed(eventIdentifier, fundAmount);
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
}
