// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    

    function run() external returns (FundMe){
        HelperConfig hc = new HelperConfig();
        (address priceFeedAddress) = hc.activeNetworkConfig();
        vm.startBroadcast();

        FundMe fm = new FundMe(priceFeedAddress);

        vm.stopBroadcast();

        return fm;
    }
}