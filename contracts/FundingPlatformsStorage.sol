// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./FundingLibrary.sol";
import "hardhat/console.sol";

/**
 * @dev Контракт хранилище на събития
 */
contract FundingPlatformsStorage {
    // internal variables
    // ------------------------------------

    // Мап с данни за всяко създадено събитие
    mapping(uint256 => FundingLibrary.ProjectData) internal fundingPlatforms;
    // Мап с уникални идентификатор
    mapping(uint256 => bool) internal createdEvents;

    // External functions
    // ------------------------------------

    /**
     * @notice  Създване на събитие.
     * @dev     Добавяме запис в мап с ключ идентификатор и мап за използвани идентификатори
     * @param   eventIdentifier Уникален идентификатор на събитието.
     * @param   title Банер на събитието.
     * @param   purpose Цел за която се събират средства.
     * @param   fundingGoal Средствата, които са нужни.
     * @param   startTimestamp Начална дата на събитието.
     * @param   endTimestamp Крайна дата на събитието.
     */
    function createEvent(
        uint256 eventIdentifier,
        string memory title,
        string memory purpose,
        uint256 fundingGoal,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) external isCreationAllowed(eventIdentifier) {
        FundingLibrary.ProjectData storage eventData = fundingPlatforms[
            eventIdentifier
        ];
        eventData.name = title;
        eventData.purpose = purpose;
        eventData.fundingGoal = fundingGoal;
        eventData.eventStartTimestamp = startTimestamp;
        eventData.eventEndTimestamp = endTimestamp;

        createdEvents[eventIdentifier] = true;
    }

    // Internal functions
    // ------------------------------------

    /**
     * @dev Проверяваме дали вече идентификатора за събитието е използван
     */
    function _isIdentifierAlreadyUsed(uint256 eventIdentifier) internal view {
        require(
            createdEvents[eventIdentifier] == false,
            "Already exists event with Identifier"
        );
    }

    // Modifiers
    // ------------------------------------

    /**
     * @dev Проверка дали е позволено да добавяме събитие
     */
    modifier isCreationAllowed(uint256 eventIdentifier) {
        _isIdentifierAlreadyUsed(eventIdentifier);
        _;
    }
}
