// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./FundingPlatformsManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Контракт за събиране на средства спряло дадена кампания
 */
contract CrowdFundingPlatform is Ownable, FundingPlatformsManager {
    // External function
    // ------------------------------------

    /**
     * @notice  Функция, чрез която даряваме средства за дадено събитие.
     * @dev     .
     * @param   eventIdentifier Уникален идентификатор на събитието.
     */
    function fund(
        uint256 eventIdentifier
    ) external payable isFundingAllowed(eventIdentifier, msg.value) {
        _accountEventFund(eventIdentifier, msg.value);
    }

    /**
     * @notice  Функция, чрез, която даритеря си връща парите
     * @dev     .
     * @param   eventIdentifier Уникален идентификатор на събитието.
     */
    function refund(
        uint256 eventIdentifier
    ) external payable isRefundAllowed(eventIdentifier, msg.value) {
        _accountEventRefund(eventIdentifier, msg.value);
    }

    /**
     * @notice  Функция, чрез която основателя на събитие изтегля средствата
     * @dev     .
     * @param   eventIdentifier Уникален идентификатор на събитието.
     */
    function withdrawFunds(
        uint256 eventIdentifier
    ) external payable onlyOwner isWithdrawAllowed(eventIdentifier) {
        (bool sent, ) = msg.sender.call{value: getEventFundings(eventIdentifier)}("");
        require(sent, "Failed to send Ether");
    }
}
