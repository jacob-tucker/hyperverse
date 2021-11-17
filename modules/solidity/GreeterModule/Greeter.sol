//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "../IHyperverseModule.sol";

contract Greeter is IHyperverseModule {
    string private greeting;
    address private _factoryContract;

    constructor()
        IHyperverseModule(
            "Hello World",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net",
            new bytes[](0)
        )
    {}

    modifier isFactory() {
        require(
            msg.sender == _factoryContract,
            "The msgsender must be the factory contract"
        );
        _;
    }

    function init(string memory _greeting) external {
        _factoryContract = msg.sender;
        // console.log("Factory Contract Addy is :", _factoryContract);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        // console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
