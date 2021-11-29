//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./IHyperverseModule.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Tribes.sol";

contract NFTTribes is IHyperverseModule {
    Tribes tribesContract;

    struct Tenant {
        ;
    }

    constructor()
        IHyperverseModule(
            "NFTTribes",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net"
        )
    {
        tribesContract = Tribes(0x01);
    }
}
