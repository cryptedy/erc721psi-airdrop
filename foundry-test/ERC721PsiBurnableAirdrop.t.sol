// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import {ERC721PsiBurnableAirdrop} from "contracts/ERC721PsiBurnableAirdrop.sol";
import {MockForFoundry} from "contracts/mock/MockForFoundry.sol";

// test helper
import "forge-std/Test.sol";
import {TestHelpers} from "./helper/TestHelpers.t.sol";

// Sample Test Commnad
// forge test --match-contract ERC721PsiBurnableAirdrop --match-test testAirdrop
// forge inspect ERC721PsiBurnableAirdrop storage-layout --pretty

contract ERC721PsiBurnableAirdropTest is Test, TestHelpers {
    using stdStorage for StdStorage;

    MockForFoundry public token;

    // value for constructor
    string name_ = "Mock";
    string symbol_ = "MOCK";
    uint256 airdropAmount = 10_000;

    // internal value
    uint256 internal constant MAX_AMOUNT_ADDRESS = 1200;

    function setUp() public onlyOwner {
        token = new MockForFoundry(name_,symbol_,airdropAmount);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                            METADATA
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testCheckMetaData() public {
        assertEq(token.name(), name_);
        assertEq(token.symbol(), symbol_);
        assertEq(token.AIRDROP_AMOUNT(), airdropAmount);
        assertEq(token.nextTokenId(), 0);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                            Airdrop function
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    // check airdrop
    function testAppendAirdropAddresses(address[] memory candidates, address targetAddr, uint256 targetIndex) public {
        vm.assume(100 < candidates.length);
        vm.assume(targetIndex < candidates.length);
        vm.assume(targetAddr != zeroAddress);

        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);
        assertEq(addresslist.length, airdropAmount);

        // insert target address in address list
        addresslist[targetIndex] = targetAddr;

        // count target address in address list
        uint256 targetAmount = countValueFromArray(addresslist, targetAddr);

        // set address list
        token.appendAirdropAddresses(addresslist);

        // airdrop
        token.airdrop();

        // check airdrop amount
        assertEq(token.nextTokenId(), airdropAmount);

        // check airdrop target amount
        assertEq(token.balanceOf(targetAddr), targetAmount);

        // check airdroped value from 0 to 1
        bytes32 airdroped = vm.load(address(token), bytes32(uint256(9)));
        assertEq(uint256(airdroped), 1);

        // @@@ attention @@@
        // Should not be used due to long test time　about 6600s when airdropAmount = 10_000
        // check all address
        // create unique array from address list (not same value)
        // address[] memory uniqueArray = removeDuplicates(addresslist);

        // for (uint256 i = 0; i < uniqueArray.length; i++) {
        //     assertEq(token.balanceOf(uniqueArray[i]), countValueFromArray(addresslist, uniqueArray[i]));
        // }
    }

    function testNotAirdropBecauseShortArray(address[] memory candidates, address targetAddr, uint256 targetIndex)
        public
    {
        vm.assume(100 < candidates.length);
        vm.assume(candidates.length < airdropAmount);
        vm.assume(targetIndex < candidates.length);
        vm.assume(targetAddr != zeroAddress);

        // create address list && not zero address
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);

        // insert target address in address list
        addresslist[targetIndex] = targetAddr;

        // set address list
        token.appendAirdropAddresses(addresslist);

        // airdrop
        vm.expectRevert();
        token.airdrop();

        // check revert
        assertEq(token.balanceOf(targetAddr), 0);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                            AirDrop
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testAirdrop() public {
        // check airdroped init value = 0
        bytes32 airdroped = vm.load(address(token), bytes32(uint256(9)));
        assertEq(uint256(airdroped), 0);

        // check not airdrop when not set airdrop address
        vm.expectRevert();
        token.airdrop();

        // check not airdroped when already airdroped
        vm.store(address(token), bytes32(uint256(9)), bytes32(uint256(1)));
        airdroped = vm.load(address(token), bytes32(uint256(9)));
        assertEq(uint256(airdroped), 1);

        vm.expectRevert(bytes("Already airdroped"));
        token.airdrop();
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                            ownerOf
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testOwnerOf(address[] memory candidates, uint256 targetIndex) public {
        vm.assume(100 < candidates.length);
        vm.assume(targetIndex < candidates.length);

        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);
        assertEq(addresslist.length, airdropAmount);

        // set address list && airdrop
        token.appendAirdropAddresses(addresslist);
        token.airdrop();

        // check ownerOf
        assertEq(token.ownerOf(targetIndex), addresslist[targetIndex]);
    }

    function testNotOwnerOf(address[] memory candidates, uint256 targetIndex) public {
        vm.assume(100 < candidates.length);
        vm.assume(targetIndex < candidates.length);

        // not working because of out of index
        vm.expectRevert(bytes("ERC721Psi: owner query for nonexistent token"));
        token.ownerOf(targetIndex);

        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);
        assertEq(addresslist.length, airdropAmount);

        // set address list && airdrop
        token.appendAirdropAddresses(addresslist);
        token.airdrop();

        // not working because of out of index
        vm.expectRevert(bytes("ERC721Psi: owner query for nonexistent token"));
        token.ownerOf(airdropAmount + 1);
    }

    function testBurnedOwnerOf(address[] memory candidates, uint256 targetIndex) public {
        vm.assume(100 < candidates.length);
        vm.assume(targetIndex < candidates.length);

        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);
        assertEq(addresslist.length, airdropAmount);

        // set address list && airdrop
        token.appendAirdropAddresses(addresslist);
        token.airdrop();

        // check ownerOf
        assertEq(token.ownerOf(targetIndex), addresslist[targetIndex]);

        // burn
        token.burn(targetIndex);

        // not working because of out of index
        vm.expectRevert(bytes("ERC721Psi: owner query for nonexistent token"));
        token.ownerOf(targetIndex);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                        appendAirdropAddresses
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testNotSetAirdropAddressBecauseZeroAddress(address[] memory candidates, uint256 index) public {
        vm.assume(index < candidates.length);

        // create address list && zero address
        candidates[index] = zeroAddress;

        // set address list
        vm.expectRevert(bytes("contains address zero"));
        token.appendAirdropAddresses(candidates);
    }

    function testNotAddCandidates(address[] calldata candidates1, address[] calldata candidates2, uint256 targetIndex)
        public
    {
        vm.assume(100 < candidates1.length);
        vm.assume(100 < candidates2.length);
        vm.assume(targetIndex < airdropAmount);

        // create address list
        // && not zero address
        // && not target address
        // && array length == airdropAmount
        address[] memory addresslist1 = removeValueFromArray(candidates1, zeroAddress);
        addresslist1 = createAddressLists(addresslist1, airdropAmount / 2);

        address[] memory addresslist2 = removeValueFromArray(candidates2, zeroAddress);
        addresslist2 = createAddressLists(addresslist2, airdropAmount - airdropAmount / 2);

        // set address list
        token.appendAirdropAddresses(addresslist1);
        token.appendAirdropAddresses(addresslist2);

        // check not add candidates
        vm.expectRevert(bytes("invalid index"));
        token.airdrop();
    }

    function testNotRewriteCandidates(
        address[] calldata candidates1,
        address[] calldata candidates2,
        uint256 targetIndex
    ) public {
        vm.assume(100 < candidates1.length);
        vm.assume(100 < candidates2.length);
        vm.assume(targetIndex < airdropAmount);

        // create address list
        // && not zero address
        // && not target address
        // && array length == airdropAmount
        address[] memory addresslist1 = removeValueFromArray(candidates1, zeroAddress);
        addresslist1 = createAddressLists(addresslist1, airdropAmount);

        address[] memory addresslist2 = removeValueFromArray(candidates2, zeroAddress);
        addresslist2 = createAddressLists(addresslist2, airdropAmount);

        // set address list
        token.appendAirdropAddresses(addresslist1);
        token.appendAirdropAddresses(addresslist2);
        token.airdrop();

        // check not rewrite candidates
        assertEq(token.getAirdropAddress(targetIndex), addresslist1[targetIndex]);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                        getAirdropAddress
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testGetAirdropAddress(address[] memory candidates, uint256 targetIndex) public {
        vm.assume(100 < candidates.length);
        vm.assume(targetIndex < candidates.length);

        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);

        // set address list && airdrop
        token.appendAirdropAddresses(addresslist);
        token.airdrop();

        // check getAirdropAddress
        assertEq(token.getAirdropAddress(targetIndex), addresslist[targetIndex]);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                        check reports
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    // check reports not test
    function testEncode(address[] memory candidates) public {
        vm.assume(100 < candidates.length);

        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);

        (bytes memory data, uint256 gas) = token.encode(addresslist);

        // reports
        emit log_uint(gas);
    }

    // check reports not test
    function testDecode(address[] memory candidates, uint256 tokenId) public {
        vm.assume(100 < candidates.length);
        vm.assume(tokenId < airdropAmount);
        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);

        token.appendAirdropAddresses(addresslist);

        uint256 outer = tokenId / MAX_AMOUNT_ADDRESS;
        uint256 inner = tokenId % MAX_AMOUNT_ADDRESS;

        (address addr, uint256 gas) = token.decode(outer, inner);

        // reports
        emit log_uint(gas);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                        check reports
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testEncodeFix(address[] memory candidates) public {
        vm.assume(100 < candidates.length);

        // create address list
        // && not zero address
        // && array length == airdropAmount
        address[] memory addresslist = removeValueFromArray(candidates, zeroAddress);
        addresslist = createAddressLists(addresslist, airdropAmount);

        (bytes memory data, uint256 gas) = token.encode(addresslist);

        // reports
        emit log_uint(gas);
    }

    /*//////////////////////////////////////////////////////////////////////////////////////////////////
                                        helper function
    //////////////////////////////////////////////////////////////////////////////////////////////////*/

    function createAddressLists(address[] memory array, uint256 length) public pure returns (address[] memory) {
        address[] memory result = new address[](length);

        uint256 index = 0;
        for (uint256 i = 0; i < length; i++) {
            result[i] = array[index];
            index++;
            if (index == array.length) {
                index = 0;
            }
        }
        return result;
    }

    function removeValueFromArray(address[] memory array, address addr) public pure returns (address[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] != addr) {
                count++;
            }
        }
        address[] memory result = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] != addr) {
                result[index] = array[i];
                index++;
            }
        }
        return result;
    }

    function countValueFromArray(address[] memory array, address addr) public pure returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == addr) {
                count++;
            }
        }
        return count;
    }

    function removeDuplicates(address[] memory array) public pure returns (address[] memory) {
        address[] memory uniqueArray = new address[](array.length);

        uint256 index = 0;
        for (uint256 i = 0; i < array.length; i++) {
            bool isDuplicate = false;
            for (uint256 j = 0; j < index; j++) {
                if (uniqueArray[j] == array[i]) {
                    isDuplicate = true;
                    break;
                }
            }
            if (!isDuplicate) {
                uniqueArray[index] = array[i];
                index++;
            }
        }

        address[] memory result = new address[](index);
        for (uint256 i = 0; i < index; i++) {
            result[i] = uniqueArray[i];
        }
        return result;
    }
}
