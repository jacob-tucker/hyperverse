//npx hardhat run scripts/nft-tribes-script.js
const hre = require("hardhat");
async function main() {

    // This deploys the "Tribes" contract
    const Tribes = await hre.ethers.getContractFactory("Tribes");
    const tribesContract = await Tribes.deploy();
    await tribesContract.deployed();

    console.log("Tribes Contract deployed to:", tribesContract.address);

    // This deploys the "NFTTribes" contract
    const NFTTribes = await hre.ethers.getContractFactory("NFTTribes");
    const nftTribesContract = await NFTTribes.deploy(tribesContract.address);
    await nftTribesContract.deployed();

    console.log("NFTTribes Contract deployed to:", nftTribesContract.address);

    // This creates a new Tenant "instance" for the msg.sender
    await tribesContract.createInstance();

    // Yeah yeah
    const name = hre.ethers.utils.formatBytes32String("Merkle");
    const ipfsHash = hre.ethers.utils.formatBytes32String("ipfslinkHere");
    const description = hre.ethers.utils.formatBytes32String("Merkles like apples");

    // Creates a new tribe, passing in the Tenant address (the same as msg.sender above)
    const createNewTribe = await tribesContract.addNewTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        name, ipfsHash, description
    );
    const event = await createNewTribe.wait();
    console.log(event.events[0].event);

    const getTribeData = await tribesContract.getTribeData(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        1
    );
    // Gets the tribe data back and converts it from bytes -> string
    console.log({
        tribeName: hre.ethers.utils.parseBytes32String(getTribeData[0]),
        ipfsHash: hre.ethers.utils.parseBytes32String(getTribeData[1]),
        description: hre.ethers.utils.parseBytes32String(getTribeData[2])
    });

    const joinTribe = await tribesContract.joinTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        1
    );

    const getUserTribe = await tribesContract.getUserTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );

    console.log(hre.ethers.utils.parseBytes32String(getUserTribe));

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });