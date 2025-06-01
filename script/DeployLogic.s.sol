// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ScholarshipDispenser} from "src/ScholarshipDispenser.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        ScholarshipDispenser deployedContract = new ScholarshipDispenser();

        console2.log(
            "Deployed ScholarshipDispenser at:",
            address(deployedContract)
        );
        vm.stopBroadcast();
    }
}
