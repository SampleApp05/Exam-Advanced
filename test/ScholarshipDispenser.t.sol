// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {ScholarshipDispenserFactory} from "src/ScholarshipDispenserFactory.sol";
import {ScholarshipDispenser} from "src/ScholarshipDispenser.sol";
import {IScholarshipDispenser} from "src/interfaces/IScholarshipDispenser.sol";
import {MockAggregatorV3} from "./Mocks/MockAggregatorV3.sol";

contract ScholarshipDispenserTests is Test {
    event ScholarshipClaimed(address indexed student);
    event DispenserFunded(uint256 amount);
    event LeftoverFundsWithdrawn(uint256 amount);

    ScholarshipDispenser public sut;
    MockAggregatorV3 public mockPriceFeed;

    address public student;
    uint256 directorKey =
        0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
    address public director;

    string public departmentName = "Engineering";
    string public version = "1.0.0";
    bytes32 public participantListHash =
        0xa2eed7aeae7cae27a7ddfd17c6508772d8da89762745b4c80f6cf1bf7d2be24b;
    uint256 scholarshipCentAmount = 500; // 5.00 USD
    uint256 claimDeadline = block.timestamp + 30 days;

    bytes32 proofOne =
        0xe044d8ae0a8cc625cc4fc5181f2212d9fe806027579c9f793be41734c410c972;
    bytes32[] proof = [proofOne];

    function setUp() public {
        student = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        director = vm.addr(directorKey);
        vm.deal(director, 10_000 ether);

        ScholarshipDispenser implementation = new ScholarshipDispenser();
        ScholarshipDispenserFactory factory = new ScholarshipDispenserFactory(
            address(implementation),
            director
        );

        mockPriceFeed = new MockAggregatorV3(100000000, 8); // 1 ETH = 1 USD

        vm.startPrank(director);
        address payable proxy = factory.createDispenser(
            departmentName,
            participantListHash,
            scholarshipCentAmount,
            address(mockPriceFeed),
            claimDeadline
        );

        sut = ScholarshipDispenser(proxy);

        vm.stopPrank();
    }

    function testFund() public {
        vm.startPrank(director);

        uint256 amount = 1000 ether;

        vm.expectEmit(true, true, true, true);
        emit DispenserFunded(amount);

        sut.fund{value: amount}();

        assertEq(address(sut).balance, amount);
        assertEq(director.balance, 10_000 ether - amount);

        vm.stopPrank();
    }

    function testWithdrawLeftoverFunds() public {
        uint256 amount = 1000 ether;

        vm.warp(claimDeadline + 1 days); // fast forward in time
        vm.roll(block.number + 1);

        vm.startPrank(director);

        sut.fund{value: amount}();

        vm.expectEmit(true, true, true, true);
        emit LeftoverFundsWithdrawn(amount);

        sut.withdrawLeftoverFunds();
        vm.stopPrank();

        assertEq(address(sut).balance, 0);
        assertEq(director.balance, 10_000 ether);
    }

    function testWithdrawRevert() public {
        vm.startPrank(director);

        vm.expectRevert(IScholarshipDispenser.ClaimPeriodNotFinished.selector);
        sut.withdrawLeftoverFunds();

        vm.stopPrank();
    }

    function testClaimScholarship() public {
        vm.prank(director);
        sut.fund{value: 1000 ether}(); // Fund the dispenser

        vm.startPrank(student);

        vm.expectEmit(true, true, true, true);
        emit ScholarshipClaimed(student);

        sut.claimScholarship(proof);

        assertEq(address(sut).balance, 1000 ether - 5 ether); // 1 USD = 1 ETH
        assertEq(student.balance, 5 ether); // 5.00 USD in ETH

        vm.stopPrank();
    }

    function testClaimDeadlinePassedRevert() public {
        vm.prank(director);
        sut.fund{value: 1000 ether}(); // Fund the dispenser

        vm.warp(claimDeadline + 1 days); // fast forward in time
        vm.roll(block.number + 1);

        vm.startPrank(student);

        vm.expectRevert(IScholarshipDispenser.ClaimPeriodFinished.selector);
        sut.claimScholarship(proof);

        vm.stopPrank();
    }

    function testAlreadyClaimedRevert() public {
        vm.prank(director);
        sut.fund{value: 1000 ether}(); // Fund the dispenser

        vm.startPrank(student);

        sut.claimScholarship(proof); // First claim should succeed

        vm.expectRevert(
            IScholarshipDispenser.ScholarshipAlreadyClaimed.selector
        );
        sut.claimScholarship(proof); // Second claim should revert

        vm.stopPrank();
    }

    function testInvalidPriceFeedDataRevert() public {
        vm.prank(director);
        sut.fund{value: 1000 ether}(); // Fund the dispenser

        vm.startPrank(student);

        // Set an invalid price in the mock price feed
        mockPriceFeed.setLatestPrice(0); // Set price to 0

        vm.expectRevert(IScholarshipDispenser.InvalidPriceFeedData.selector);
        sut.claimScholarship(proof);

        vm.stopPrank();
    }

    function testUnauthorizedStudentRevert() public {
        vm.prank(director);
        sut.fund{value: 1000 ether}(); // Fund the dispenser

        address unauthorizedStudent = 0x1234567890123456789012345678901234567890;
        vm.startPrank(unauthorizedStudent);

        vm.expectRevert(IScholarshipDispenser.UnauthorizedStudent.selector);
        sut.claimScholarship(proof);

        vm.stopPrank();
    }
}
