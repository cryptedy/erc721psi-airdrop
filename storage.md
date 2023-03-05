| Name                | Type                                         | Slot | Offset | Bytes | Contract                                                        |
| ------------------- | -------------------------------------------- | ---- | ------ | ----- | --------------------------------------------------------------- |
| \_batchHead         | struct BitMaps.BitMap                        | 0    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| \_name              | string                                       | 1    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| \_symbol            | string                                       | 2    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| \_owners            | mapping(uint256 => address)                  | 3    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| \_currentIndex      | uint256                                      | 4    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| \_tokenApprovals    | mapping(uint256 => address)                  | 5    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| \_operatorApprovals | mapping(address => mapping(address => bool)) | 6    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| \_burnedToken       | struct BitMaps.BitMap                        | 7    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| airdropPointers     | address[]                                    | 8    | 0      | 32    | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
| airdroped           | bool                                         | 9    | 0      | 1     | contracts/ERC721PsiBurnableAirdrop.sol:ERC721PsiBurnableAirdrop |
