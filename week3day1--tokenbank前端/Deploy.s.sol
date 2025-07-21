// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/BaseERC20.sol";
import "../src/TokenBank.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署 BaseERC20
        BaseERC20 token = new BaseERC20();
        console.log("BaseERC20 deployed to:", address(token));

        // 部署 TokenBank
        TokenBank tokenBank = new TokenBank(address(token));
        console.log("TokenBank deployed to:", address(tokenBank));

        vm.stopBroadcast();
    }
}
