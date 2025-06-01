// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

interface IScholarshipDispenser {
    // MARK: -Errors
    error InvalidAddress();
    error InvalidScholarshipAmount();
    error InvalidPriceFeedContract();
    error InvalidClaimDeadline();

    error UnauthorizedStudent();
    error ScholarshipAlreadyClaimed();
    error ScholarshipTransferFailed();
    error InsufficientScholarshipBalance();
    error ClaimPeriodFinished();

    error InvalidFundingAmount();
    error ClaimPeriodNotFinished();
    error NoLeftoverFunds();
    error ETHTransferFailed();
    error InvalidPriceFeedData();

    // MARK: - Events
    event ScholarshipClaimed(address indexed student);
    event DispenserFunded(uint256 amount);
    event LeftoverFundsWithdrawn(uint256 amount);

    // MARK: - Functions
    function director() external view returns (address);
    function departmentName() external view returns (string memory);
    function participantListHash() external view returns (bytes32);
    function scholarshipCentAmount() external view returns (uint256);
    function priceFeedContract() external view returns (AggregatorV3Interface);
    function claimDeadline() external view returns (uint256);
    function claimStatus(address student) external view returns (bool);

    function initialize(
        address director,
        string calldata _departmentName,
        bytes32 _participantListHash,
        uint256 _scholarshipCentAmount,
        address _priceFeedContract,
        uint256 _claimDeadline
    ) external;

    function fund() external payable;
    function claimScholarship(bytes32[] memory proof) external;
    function withdrawLeftoverFunds() external;
}
