// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "../ERC721PsiBurnableAirdrop.sol";

contract Mock is ERC721PsiBurnableAirdrop{
    constructor() ERC721PsiBurnableAirdrop("Mock", "MOCK", 1500){
        
    }

    function appendAirdropAddresses(address[] memory candidates) external {
        _appendAirdropAddresses(candidates);
    }


    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function safeMint(address to, uint256 quantity) public {
        _safeMint(to, quantity);
    }

    function safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) public {
        _safeMint(to, quantity, _data);
    }

    function getBatchHead(
        uint256 tokenId
    ) public view {
        _getBatchHead(tokenId);
    }

    function burn(
        uint256 tokenId
    ) public {
        _burn(tokenId);
    }


    function burn(uint256 start, uint256 num) public {
        uint256 end = start + num;
        for(uint256 i=start;i<end;i++){
            _burn(i);
        }
    }
}