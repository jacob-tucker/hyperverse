//npx hardhat run scripts/tribes-new-script.js
const hre = require("hardhat");
async function main() {

    // This deploys the "TribesNew" contract
    const TribesNew = await hre.ethers.getContractFactory("TribesNew");
    const tribesNewContract = await TribesNew.deploy();
    await tribesNewContract.deployed();

    console.log("TribesNew Contract deployed to:", tribesNewContract.address);

    // This creates a new Tenant "instance" for the msg.sender
    await tribesNewContract.createInstance();

    // Yeah yeah
    const name = hre.ethers.utils.formatBytes32String("Merkle")
    const ipfsHash = hre.ethers.utils.formatBytes32String("ipfslinkHere")
    const description = hre.ethers.utils.formatBytes32String("Merkles like apples")

    // Creates a new tribe, passing in the Tenant address (the same as msg.sender above)
    const createNewTribe = await tribesNewContract.addNewTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        name, ipfsHash, description
    );
    const event = await createNewTribe.wait();
    console.log(event.events[0].event)

    const getTribeData = await tribesNewContract.getTribeData(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        name
    );
    // Gets the tribe data back and converts it from bytes -> string
    console.log({
        tribeName: hre.ethers.utils.parseBytes32String(getTribeData[0]),
        ipfsHash: hre.ethers.utils.parseBytes32String(getTribeData[1]),
        description: hre.ethers.utils.parseBytes32String(getTribeData[2])
    });

    const joinTribe = await tribesNewContract.joinTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        name
    );

    const getUserTribe = await tribesNewContract.getUserTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );

    console.log(hre.ethers.utils.parseBytes32String(getUserTribe))

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });