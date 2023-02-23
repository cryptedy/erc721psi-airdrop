// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "solidity-bits/contracts/BitMaps.sol";
import "./extension/ERC721PsiBurnable.sol";
import "solmate/src/utils/SSTORE2.sol";
import "hardhat/console.sol";

abstract contract ERC721PsiBurnableAirdrop is ERC721PsiBurnable {
    using BitMaps for BitMaps.BitMap;

    address[] private airdropPointers;
    uint256 internal constant MAX_AMOUNT_ADDRESS = 1200;
    uint256 public immutable AIRDROP_AMOUNT;

    bool airdroped;

    constructor (string memory name_, string memory symbol_, uint256 airdropAmount) ERC721Psi(name_, symbol_){
        AIRDROP_AMOUNT = airdropAmount;
    }

    function _airdrop() internal virtual{
        if (airdroped) revert("Already airdroped");
        // set all bitmap
        _batchHead.setBatch(0, AIRDROP_AMOUNT);
        // 
        _currentIndex = AIRDROP_AMOUNT;
        // emit Transfer
        // Emit events
        for(uint256 tokenId = _startTokenId(); tokenId < _startTokenId() + AIRDROP_AMOUNT; tokenId++){
            emit Transfer(address(0), getAirdropAddress(tokenId), tokenId);
        } 
        airdroped = true;
    }

    function nextTokenId() public view returns(uint256){
        return _currentIndex;
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = super.ownerOf(tokenId);
        if (owner == address(0) && !_burnedToken.get(tokenId)){
            owner = getAirdropAddress(tokenId);
        }
        return owner;
    }
    /*
    function _appendAirdropAddresses(address[] memory candidates) internal virtual{
        airdropPointers.push(SSTORE2.write(_encode(candidates)));
    }
    */
    function _appendAirdropAddresses(address[] memory candidates) internal virtual{
        // address amount
        uint256 amount = candidates.length;
        // division count of address list per 1200. An address has 20 bytes and
        // contract size is restricted under 24KB, this split list by 1200 addresses.
        uint256 division = amount / MAX_AMOUNT_ADDRESS + 1;
        // prepare input count
        uint256 inputCount = MAX_AMOUNT_ADDRESS;
        // write input
        for (uint256 i = 0; i < division; i++){
            if (( i + 1) == division) {
                inputCount = amount - (i * MAX_AMOUNT_ADDRESS);
            }
            // copy candidates
            address[] memory input = new address[] (inputCount);
            for (uint j = 0; j < inputCount; j++){
                input[j] = candidates[j + i * MAX_AMOUNT_ADDRESS];
                if (input[j] == address(0)) revert("contains address zero");
            }
            airdropPointers.push(SSTORE2.write(_encode(input)));
        }
    }
    function getAirdropAddress(uint256 tokenId) public view returns(address addr){
        uint256 outer = tokenId / MAX_AMOUNT_ADDRESS;
        uint256 inner = tokenId % MAX_AMOUNT_ADDRESS;
        return _decode(airdropPointers[outer], inner);
    }

    function encode(address[] memory input) public view returns(bytes memory data, uint256 gas){
        gas = gasleft();
        bytes32[] memory inputBytes;
        assembly{
            inputBytes := input
        }
        data = _encodeFix(inputBytes, 20);
        gas -= gasleft();
    }

    function decode(uint256 outer, uint256 inner) public view returns(address addr, uint256 gas){
        gas = gasleft();
        addr = _decode(airdropPointers[outer], inner);
        gas -= gasleft();
    }

    function _encode(address[] memory input) internal pure returns(bytes memory data){
        bytes32[] memory inputBytes;
        assembly{
            inputBytes := input
        }
        return _encodeFix(inputBytes, 20);
    }

    function _encodeFix(bytes32[] memory input, uint8 elemSize) private pure returns(bytes memory data){
        uint256 len = input.length;
        if (len == 0) revert();
        assembly{
            // data size: [] means byte(s)
            // [1] identifier of array type
            // [2] length of elements
            // [elemSize * length of elements] bodies of elements
            let dataSize := add(3, mul(elemSize, len))
            // refer free memory pointer
            data := mload(0x40)
            // set data size
            mstore(data, dataSize)
            // prepare pointer to write `data`
            let ptrData := add(data, 0x20)
            // shift free memory pointer (add 1 word to prevent overwrite by mstore)
            mstore(0x40, add(add(ptrData, dataSize), 0x20))
            // set identifier and length of elements
            let temp := or(shl(248, elemSize), shl(232, len))
            mstore(ptrData, temp)
            // shift pointer
            ptrData := add(ptrData, 3)
            // write elements
            let ptrInput := add(input, 0x20)
            for {let i := 0} lt(i, len) {i := add(i, 1)}{
                // write element
                mstore(ptrData, shl(mul(sub(0x20, elemSize), 8), mload(ptrInput)))
                // shift pointer
                ptrInput := add(ptrInput, 0x20)
                ptrData := add(ptrData, elemSize)
            }
        }
    }

    function _decode(address pointer, uint256 index) internal view returns(address addr){
        // read header
        bytes memory header = SSTORE2.read(pointer, 0, 3);
        // length
        uint256 length;
        // check header
        assembly {
            // load header on stuck
            let stuckHeader := mload(add(header, 0x20))
            // check element size as address(20bytes)
            if iszero(eq(shr(248, stuckHeader), 20)){
                revert(0,0)
            }
            // get length of elements
            length := shr(240, shl(8, stuckHeader))
        }
        // check bound of index
        if (index >= length) revert("invalid index");
        // calc position
        uint256 pos = 3 + index * 20;
        // read element
        bytes memory data = SSTORE2.read(pointer, pos, pos + 20);
        // change endian and store address on return variable
        assembly {
            addr := shr(96, mload(add(data, 0x20)))
        }
    } 

}