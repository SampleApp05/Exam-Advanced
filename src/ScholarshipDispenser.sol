// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IScholarshipDispenser} from "src/interfaces/IScholarshipDispenser.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ScholarshipDispenser is OwnableUpgradeable, IScholarshipDispenser {
    // added for withdrawLeftoverFunds logic
    uint256 public constant MIN_CLAIM_PERIOD = 900 seconds; // (15min) low on purpose to allow testing on sepolia
    uint256 public constant MAX_CLAIM_PERIOD = 90 days;

    string public departmentName;
    uint256 public scholarshipCentAmount;
    uint256 public claimDeadline;
    AggregatorV3Interface public priceFeedContract;
    bytes32 public participantListHash;

    mapping(address => bool) public claimStatus; // could hash(address+signature => bool) if we want to allow multiple claims

    constructor() {
        _disableInitializers();
    }

    // MARK: - Private
    function zeroAddress() private pure returns (address) {
        return address(0);
    }

    // MARK: - Internal
    function _verifyStudent(
        address target,
        bytes32[] memory proof
    ) internal view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(target))));
        return MerkleProof.verify(proof, participantListHash, leaf);
    }

    function _convertScholarshipToWei() internal view returns (uint256) {
        uint256 currentPrice = _fetchCurrentPrice();
        return
            (scholarshipCentAmount *
                10 ** 16 *
                10 ** priceFeedContract.decimals()) / currentPrice;
    }

    function _fetchCurrentPrice() internal view returns (uint256) {
        (, int256 price, , , ) = priceFeedContract.latestRoundData();
        require(price > 0, InvalidPriceFeedData());

        return uint256(price);
    }

    function _transferScholarshipTo(address student) internal {
        uint256 amount = _convertScholarshipToWei();
        require(
            address(this).balance + 1 > amount,
            InsufficientScholarshipBalance()
        );

        (bool success, ) = payable(student).call{value: amount}("");

        require(success, ScholarshipTransferFailed());
    }

    function claimScholarship(bytes32[] memory proof) public {
        require(claimDeadline + 1 > block.timestamp, ClaimPeriodFinished());

        address student = msg.sender;

        require(claimStatus[student] == false, ScholarshipAlreadyClaimed());
        claimStatus[student] = true;

        require(_verifyStudent(student, proof), UnauthorizedStudent());

        _transferScholarshipTo(student);
        emit ScholarshipClaimed(student);
    }

    // MARK: - External
    function director() external view returns (address) {
        return owner();
    }

    function initialize(
        address _director,
        string calldata _departmentName,
        bytes32 _participantListHash,
        uint256 _scholarshipCentAmount,
        address _priceFeedContract,
        uint256 _claimDeadline
    ) external initializer {
        require(_director != zeroAddress(), InvalidAddress());
        require(_scholarshipCentAmount > 0, InvalidScholarshipAmount());
        require(
            _priceFeedContract != zeroAddress(),
            InvalidPriceFeedContract()
        ); // could do additional checks for AggregatorV3Interface

        require(
            _claimDeadline + 1 > block.timestamp + MIN_CLAIM_PERIOD &&
                _claimDeadline < block.timestamp + MAX_CLAIM_PERIOD + 1,
            InvalidClaimDeadline()
        );

        __Ownable_init(_director);

        departmentName = _departmentName;
        participantListHash = _participantListHash;
        scholarshipCentAmount = _scholarshipCentAmount;
        priceFeedContract = AggregatorV3Interface(_priceFeedContract);
        claimDeadline = _claimDeadline;
    }

    function withdrawLeftoverFunds() external onlyOwner {
        require(block.timestamp > claimDeadline, ClaimPeriodNotFinished());

        uint256 balance = address(this).balance;
        require(balance > 0, NoLeftoverFunds());

        (bool success, ) = owner().call{value: balance}("");
        require(success, ETHTransferFailed());

        emit LeftoverFundsWithdrawn(balance);
    }

    function fund() external payable onlyOwner {
        uint256 amount = msg.value;

        require(amount > 0, InvalidFundingAmount());
        // Allow contract to receive ETH only from the director(owner)
        emit DispenserFunded(amount);
    }
}
