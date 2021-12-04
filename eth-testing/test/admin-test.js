const hre = require("hardhat");
async function main() {
    const [TENANT,TENANT2, USER] = await ethers.getSigners();
    //State Contract
    const TribeState = await hre.ethers.getContractFactory('TribesState');
    const TribeStateContract = await TribeState.deploy();
    await TribeStateContract.deployed() 
    console.log("Tribes State Contract : ",TribeStateContract.address )


    //Admin Contract
    const TribesAdmin = await hre.ethers.getContractFactory('TribesAdmin');
    const TribesAdminContract = await TribesAdmin.deploy(TribeStateContract.address);
    await TribesAdminContract.deployed() 

    console.log("Tribes Admin Contract : ",TribesAdminContract.address )


    //msg.sender : 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
    await TribesAdminContract.createInstance();

 
    const name = hre.ethers.utils.formatBytes32String("Merkle");
    const ipfsHash = hre.ethers.utils.formatBytes32String("https://ipfs.io/...");
    const description = hre.ethers.utils.formatBytes32String("a group that loves apples");

    const addTribe = await TribesAdminContract.addNewTribe(
        TENANT.address,
        name, ipfsHash,description
    )

    const addTribeTxn = await addTribe.wait();
    
    const getTribe = await TribeStateContract.getTribeData(TENANT.address, 1);
    console.log(
        hre.ethers.utils.parseBytes32String(getTribe[0]), "is",
        hre.ethers.utils.parseBytes32String(getTribe[2]), "and you can view their image here:",
        hre.ethers.utils.parseBytes32String(getTribe[1])
    )

    //Admin2 Contract
    const TribesAdmin2 = await hre.ethers.getContractFactory('TribesAdmin');
    const TribesAdminContract2 = await TribesAdmin2.deploy(TribeStateContract.address);
    await TribesAdminContract2.deployed() 

    console.log("Tribes Admin Contract 2 : ",TribesAdminContract.address )

    await TribesAdminContract2.createInstance();
    const addTribe2 = await TribesAdminContract2.addNewTribe(
        TENANT.address,
        name, ipfsHash,description
    )


    const addTribeTxn2 = await addTribe2.wait();
    
    const getTribe2 = await TribeStateContract.getTribeData(TENANT.address, 2);
    console.log(
        hre.ethers.utils.parseBytes32String(getTribe2[0]), "is",
        hre.ethers.utils.parseBytes32String(getTribe2[2]), "and you can view their image here:",
        hre.ethers.utils.parseBytes32String(getTribe2[1])
    )

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });