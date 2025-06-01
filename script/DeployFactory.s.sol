// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ScholarshipDispenserFactory} from "src/ScholarshipDispenserFactory.sol";

contract DeployFactory is Script {
    function run() external {
        address logicAddress = vm.envAddress("LOGIC_CONTRACT_ADDRESS");
        address director_wallet = vm.envAddress("PRIMARY_WALLET");
        console2.log("Logic:", logicAddress);

        vm.startBroadcast();

        ScholarshipDispenserFactory factory = new ScholarshipDispenserFactory(
            logicAddress,
            director_wallet
        );
        console2.log(
            "Deployed ScholarshipDispenserFactory at:",
            address(factory)
        );

        vm.stopBroadcast();
    }
}
