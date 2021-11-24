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

    const Factory = await hre.ethers.getContractFactory("GreeterFactory");
    const factoryContract = await Factory.deploy(greeterContract.address);
    await factoryContract.deployed();

    console.log("Factory Contract deployed to:", factoryContract.address);

    let cloneTxn = await factoryContract.createGreeter(
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        "Hi Jacob"
    );
    await cloneTxn.wait();

    let cloneTxn2 = await factoryContract.createGreeter(
        "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f",
        "Hi Gel"
    );
    await cloneTxn2.wait();
    // 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f
    let greet = await factoryContract.greet(
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
    );
    let greet2 = await factoryContract.greet(
        "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f"
    );

    console.log(greet)
    console.log(greet2)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });