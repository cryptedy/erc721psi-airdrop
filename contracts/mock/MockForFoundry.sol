// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "../ERC721PsiBurnableAirdrop.sol";

contract MockForFoundry is ERC721PsiBurnableAirdrop {
    constructor(string memory name_, string memory symbol_, uint256 airdropAmount)
        ERC721PsiBurnableAirdrop(name_, symbol_, airdropAmount)
    {}

    function appendAirdropAddresses(address[] memory candidates) public {
        _appendAirdropAddresses(candidates);
    }

    function airdrop() public {
        _airdrop();
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}
