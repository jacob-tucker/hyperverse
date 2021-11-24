//npx hardhat run scripts/tribe-script.js
const hre = require("hardhat");
async function main() {

    const Tribes = await hre.ethers.getContractFactory("Tribes");
    const tribesBaseContract = await Tribes.deploy();
    await tribesBaseContract.deployed();

    console.log("Tribes Base Contract deployed to:", tribesBaseContract.address);

    const Factory = await hre.ethers.getContractFactory("TribesFactory");
    const factoryContract = await Factory.deploy(tribesBaseContract.address);
    await factoryContract.deployed();

    console.log("Factory Contract deployed to:", factoryContract.address);

    await factoryContract.createTribes();

    const name = hre.ethers.utils.formatBytes32String( "Merkle")
    const ipfsHash = hre.ethers.utils.formatBytes32String( "ipfslinkHere")
    const description = hre.ethers.utils.formatBytes32String( "Merkles like apples")
    
 
    const createNewTribe = await factoryContract.addNewTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        name, ipfsHash, description
    );
    const event = await createNewTribe.wait();
    console.log(event.events[0].event)

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });