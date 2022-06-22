//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "forge-std/Script.sol";
import "../src/SFT.sol";

contract SFTScript is Script {
    function run() public {
        vm.startBroadcast();
        SFT sft = new SFT("TestScript", "TS");
        console.log(address(sft));
        sft.mint(sft.admin(), "testURI");
        vm.stopBroadcast();
    }
}
