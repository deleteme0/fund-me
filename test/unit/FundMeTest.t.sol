// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
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

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceVersion() public{
        assertEq(fundMe.getVersion(),4);
    }

    function testFundFailsWithoutEnoughEth() public{
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundFunded() public{
        vm.prank(USER);
        fundMe.fund{value: SENDVALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);

        assertEq(amountFunded,SENDVALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SENDVALUE}();

        address funder = fundMe.getFunder(0);

        assertEq(USER,funder);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SENDVALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SENDVALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawFromSingleFunder() public funded {

        uint256 startingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //uint256 gasStart = gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd)*tx.gasprice;
        //console.log(gasUsed);

        uint256 endingOwnerBalace = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance,0);
        assertEq(startingBalance+startingFundMeBalance,endingOwnerBalace);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 staringFunderIndex = 1;

        for(uint160 i = staringFunderIndex;i<numberOfFunders;i++){
            
            hoax(address(i),SENDVALUE);
            fundMe.fund{value:SENDVALUE}();
        }

        
        uint256 startingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endBalance = fundMe.getOwner().balance;
        assertEq(address(fundMe).balance,0);
        assertEq(startingBalance + startingFundMeBalance,endBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 staringFunderIndex = 1;

        for(uint160 i = staringFunderIndex;i<numberOfFunders;i++){
            
            hoax(address(i),SENDVALUE);
            fundMe.fund{value:SENDVALUE}();
        }

        
        uint256 startingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endBalance = fundMe.getOwner().balance;
        assertEq(address(fundMe).balance,0);
        assertEq(startingBalance + startingFundMeBalance,endBalance);
    }


}