//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Tribes.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTTribes is ERC721, IHyperverseModule {
    Tribes tribesContract;
    uint256 counter;
    address owner;

    constructor(address _tenantContract)
        ERC721("Item", "ITM")
        
    {
        tribesContract = Tribes(_tenantContract);
        counter = 0;
        owner = msg.sender;
    }

    function mint(address to) public {
        require(msg.sender == owner, "Only the owner of this contract can mint.");
        _mint(to, counter);
        counter = counter + 1;
    }
 
    function joinSecretTribe(address tenant, uint256 tribeId) public {
        require(balanceOf(msg.sender) >= 3, "The caller doesn't have enough NFTs!");

        tribesContract.joinTribe(tenant, tribeId);
    }
}
