// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {ScholarshipDispenserFactory} from "src/ScholarshipDispenserFactory.sol";
import {ScholarshipDispenser} from "src/ScholarshipDispenser.sol";
import {IScholarshipDispenser} from "src/interfaces/IScholarshipDispenser.sol";

contract ScholarshipFactoryTest is Test {
    event DispenserCreated(address indexed dispenser, uint256 dispenserID);

    ScholarshipDispenser public implementation;
    ScholarshipDispenserFactory public factory;
    IScholarshipDispenser public dispenser;

    address public director = address(0x123);
    bytes32 participantListHash = keccak256("Some list of participants");

    function setUp() public {
        implementation = new ScholarshipDispenser();
        factory = new ScholarshipDispenserFactory(
            address(implementation),
            director
        );

        vm.deal(director, 1000 ether);
    }

    function testDeployement() public view {
        assertEq(factory.implementation(), address(implementation));
        assertEq(factory.dispenserCount(), 0);
        assertEq(factory.hasRole(factory.ADMIN_ROLE(), address(this)), true);
        assertEq(factory.hasRole(factory.DIRECTOR_ROLE(), director), true);
    }

    function testCreateDispenser() public {
        string memory departmentName = "Engineering";
        uint256 scholarshipCentAmount = 500; // 5.00 USD
        uint256 claimDeadline = block.timestamp + 30 days;
        address priceFeedContract = address(0x456);

        vm.startPrank(director);

        vm.expectEmit(false, false, false, true);
        emit DispenserCreated(address(0), 0);

        address payable proxy = factory.createDispenser(
            departmentName,
            participantListHash,
            scholarshipCentAmount,
            priceFeedContract,
            claimDeadline
        );

        dispenser = IScholarshipDispenser(proxy);
        dispenser.fund{value: 10 ether}();

        vm.stopPrank();

        assertTrue(proxy != address(0));
        assertEq(address(proxy), factory.dispensers(0));
        assertEq(factory.dispenserCount(), 1);

        assertEq(dispenser.director(), director);
        assertEq(dispenser.departmentName(), departmentName);
        assertEq(dispenser.participantListHash(), participantListHash);
        assertEq(dispenser.scholarshipCentAmount(), scholarshipCentAmount);
        assertEq(dispenser.claimDeadline(), claimDeadline);
        assertEq(address(dispenser.priceFeedContract()), priceFeedContract);

        assertEq(director.balance, 1000 ether - 10 ether);
        assertEq(address(dispenser).balance, 10 ether);
    }
}
