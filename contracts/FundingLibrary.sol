// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

library FundingLibrary {
    struct ProjectData {
        // Име на събитието.
        string name;
        // Цел на събитието.
        string purpose;
        // Средствата който са необоходими да се съберат.
        uint256 fundingGoal;
        // Средствата който са събрани.
        uint256 collectedAmount;
        // Начална дата на събирането на средства
        uint256 eventStartTimestamp;
        // Крайна дата на събирането на средства
        uint256 eventEndTimestamp;
    }

    struct FundingContributor{
        // Дарени средства
        uint256 funds;
    }

}
