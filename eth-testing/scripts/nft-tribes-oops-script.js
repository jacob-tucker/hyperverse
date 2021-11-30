//npx hardhat run scripts/nft-tribes-oops-script.js

const hre = require("hardhat");
async function main() {
    const [TENANT, USER] = await ethers.getSigners();

    /*********************** DEPLOYMENT ***********************/

    // This deploys the "TribesState" contract
    const TribesState = await hre.ethers.getContractFactory("TribesState");
    const tribesStateContract = await TribesState.deploy();
    await tribesStateContract.deployed();

    console.log("TribesState Contract deployed to:", tribesStateContract.address);

    // This deploys the "TribesFunctions" contract
    const TribesFunctions = await hre.ethers.getContractFactory("TribesFunctions");
    const tribesFunctionsContract = await TribesFunctions.deploy(tribesStateContract.address);
    await tribesFunctionsContract.deployed();

    console.log("TribesFunctions Contract deployed to:", tribesFunctionsContract.address);

    /*********************** STUFF ***********************/

    await tribesFunctionsContract.connect(TENANT).createInstance();

    // Restricts the Tenant's state to only be modified by TribesFunctions
    await tribesStateContract.connect(TENANT).restrictCaller(tribesFunctionsContract.address);

    // Yeah yeah
    const name = hre.ethers.utils.formatBytes32String("Merkle");
    const ipfsHash = hre.ethers.utils.formatBytes32String("https://ipfs.io/...");
    const description = hre.ethers.utils.formatBytes32String("a group that loves apples");

    // Creates a new tribe, passing in the Tenant address (the same as msg.sender above)
    await tribesFunctionsContract.connect(TENANT).addNewTribe(
        TENANT.address,
        name, ipfsHash, description
    );

    try {
        await tribesStateContract.connect(TENANT).addNewTribe(
            TENANT.address,
            name, ipfsHash, description
        );
    } catch (e) {
        console.log("You cannot call me!");
    }

    const getTribeData = await tribesStateContract.getTribeData(
        TENANT.address,
        1
    );
    // Gets the tribe data back and converts it from bytes -> string
    console.log(
        hre.ethers.utils.parseBytes32String(getTribeData[0]), "is",
        hre.ethers.utils.parseBytes32String(getTribeData[2]), "and you can view their image here:",
        hre.ethers.utils.parseBytes32String(getTribeData[1])
    );

    try {
        await tribesFunctionsContract.connect(USER).joinTribe(
            TENANT.address,
            1
        );
    } catch (e) {
        console.log("USER doesn't have enough NFTs!");
    }

    // Mint a token
    await tribesFunctionsContract.connect(TENANT).mint(
        TENANT.address,
        USER.address
    );

    console.log("TENANT minted a token to USER.");

    await tribesFunctionsContract.connect(USER).joinTribe(
        TENANT.address,
        1
    );

    console.log("USER joined a tribe.");

    const getUserTribe = await tribesStateContract.getUserTribe(
        TENANT.address,
        USER.address
    );

    console.log("USER's Tribe:", hre.ethers.utils.parseBytes32String(getUserTribe));

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });