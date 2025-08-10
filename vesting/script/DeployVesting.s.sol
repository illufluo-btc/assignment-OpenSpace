// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import {LinearVesting} from "../src/LinearVesting.sol";

contract DeployVesting is Script {
    function run(address beneficiary, address token, uint256 amount) external {
        vm.startBroadcast();
        LinearVesting vest = new LinearVesting(beneficiary, token);
        vm.stopBroadcast();

        // After deploy, holder should approve and call seed(amount) on vesting:
        // Example (CLI):
        // cast send <token> "approve(address,uint256)" <vesting> <amount> --private-key ...
        // cast send <vesting> "seed(uint256)" <amount> --private-key ...
    }
}
