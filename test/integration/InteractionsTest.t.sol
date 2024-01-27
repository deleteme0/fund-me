// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SENDVALUE = 0.1 ether ;
    uint256 constant STARTINGVALUE = 10 ether;
    uint256 constant GAS_PRICE = 1;

     function setUp() external{
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTINGVALUE);
    }

    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.deal(USER,1e18);
        //vm.prank(USER);
        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        assertEq(funder,msg.sender);
    }

}