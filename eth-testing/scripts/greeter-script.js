//npx hardhat run scripts/greeter-script.js
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const Greeter = await hre.ethers.getContractFactory("Greeter");
    const greeterContract = await Greeter.deploy();
    await greeterContract.deployed();

    console.log("Greeter Base Contract deployed to:", greeterContract.address);

    await greeterContract.createInstance(
        "Hi Jacob"
    );

    let greet = await greeterContract.greet(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );

    console.log(greet);

    await greeterContract.setGreeting(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        "Hi Gel"
    )

    let greet2 = await greeterContract.greet(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );

    console.log(greet2);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });