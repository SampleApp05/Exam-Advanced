// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ScholarshipDispenser} from "src/ScholarshipDispenser.sol";

contract ScholarshipDispenserFactory is AccessControl {
    // MARK: - Errors
    error InvalidImplementationAddress();
    error InvalidDirectorAddress();
    error InvalidFactoryAdresses();
    error UnauthorizedCaller();
    error CouldNotFundDispenser();

    // MARK: - Events
    event DispenserCreated(address indexed dispenser, uint256 dispenserID);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DIRECTOR_ROLE = keccak256("DIRECTOR_ROLE");

    address public immutable implementation;
    uint256 public dispenserCount;

    mapping(uint256 id => address dispenser) public dispensers;

    constructor(address _implementation, address director) {
        require(_implementation != address(0), InvalidImplementationAddress());
        require(director != address(0), InvalidDirectorAddress());
        require(_implementation != director, InvalidFactoryAdresses());

        implementation = _implementation;

        _grantRole(ADMIN_ROLE, msg.sender);

        _setRoleAdmin(DIRECTOR_ROLE, ADMIN_ROLE);
        _grantRole(DIRECTOR_ROLE, director);
    }

    // MARK: - Modifiers
    modifier onlyDirector() {
        require(hasRole(DIRECTOR_ROLE, msg.sender), UnauthorizedCaller());
        _;
    }

    // MARK: - External
    function createDispenser(
        string calldata departmentName,
        bytes32 participantListHash,
        uint256 scholarshipCentAmount,
        address priceFeedContract,
        uint256 claimDeadline
    ) external onlyDirector returns (address payable) {
        uint256 dispenserID = dispenserCount++; // could wrap in unchecked block since it wont likely overflow...not time to deploy to sepolia and do all the steps

        address payable dispenserAddress = payable(
            Clones.clone(implementation)
        );

        ScholarshipDispenser(dispenserAddress).initialize(
            msg.sender,
            departmentName,
            participantListHash,
            scholarshipCentAmount,
            priceFeedContract,
            claimDeadline
        );
        dispensers[dispenserID] = dispenserAddress;

        emit DispenserCreated(dispenserAddress, dispenserID);

        return dispenserAddress;
    }
}
