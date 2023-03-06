// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";

abstract contract TestHelpers is Test {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public zeroAddress = address(0);
    address public owner = vm.addr(1);
    address public user1 = vm.addr(2);
    address public user2 = vm.addr(3);
    address public user3 = vm.addr(4);
    address public anotherContractAddress = makeAddr("anotherContract");

    constructor() {}

    modifier onlyOwner() {
        vm.startPrank(owner);
        vm.deal(owner, 100 ether);
        _;
        vm.stopPrank();
    }

    modifier nonOwner() {
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);
        _;
        vm.stopPrank();
    }

    modifier User(address user) {
        vm.startPrank(user, user);
        vm.deal(user, 100 ether);
        _;
        vm.stopPrank();
    }

    modifier anotherContract() {
        vm.startPrank(user1, anotherContractAddress);
        vm.deal(user1, 100 ether);
        _;
        vm.stopPrank();
    }
}
