//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./TribesOops.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTTribesOops is ERC721, IHyperverseModule, TribesOops {
    address owner;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor()
        ERC721("Item", "ITM")
    {
        metadata = ModuleMetadata(
            "NFTTribesOops",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net"
        );

        owner = msg.sender;
    }

    function mint(address to) public {
        require(msg.sender == owner, "Only the owner of this contract can mint.");
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
    }

    function _beforeJoinTribe() view internal override {
        require(balanceOf(msg.sender) >= 1, "The caller doesn't have enough NFTs!");
    }
}
