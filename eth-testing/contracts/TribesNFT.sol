//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "./TribesState.sol";
import "./TribesFunctions.sol";
import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";

contract TribesNFT is ERC721, IHyperverseModule {
    using Counters for Counters.Counter;

    TribesState tribesState;
    TribesFunctions tribesFunctions;

    struct Tenant {
        address owner;
        Counters.Counter _tokenIds;
    }

    mapping(address => Tenant) tenants;

    constructor(address _tribesState, address _tribesFunctions)
        ERC721("Game Item", "GITM")
    {
        metadata = ModuleMetadata(
            "TribesNFT",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net"
        );
        tribesState = TribesState(_tribesState);
        tribesFunctions = TribesFunctions(_tribesFunctions);
    }

    function getState(address tenant) private view returns (Tenant storage) {
        return tenants[tenant];
    }

    function mint(address tenant, address to) public {
        require(
            msg.sender == tribesFunctions.getState(tenant).owner,
            "You are not the owner of the Tenant!"
        );
        Tenant storage state = getState(tenant);
        require(
            msg.sender == state.owner,
            "Only the owner of this contract can mint."
        );

        state._tokenIds.increment();
        uint256 newItemId = state._tokenIds.current();
        _mint(to, newItemId);
    }

    function joinTribe(address tenant, uint256 tribeId) public {
        require(
            balanceOf(msg.sender) >= 1,
            "The caller doesn't have enough NFTs!"
        );
        tribesFunctions.joinTribe(tenant, tribeId, msg.sender);
    }
}
