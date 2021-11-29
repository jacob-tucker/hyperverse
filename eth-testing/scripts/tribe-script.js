//npx hardhat run scripts/tribe-script.js
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

    const name2 = hre.ethers.utils.formatBytes32String("Merkle2")


    // Creates a new tribe, passing in the Tenant address (the same as msg.sender above)
    const createNewTribe = await tribesNewContract.addNewTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        name, ipfsHash, description
    );

    const event = await createNewTribe.wait();
    console.log(event.events[0].event)


    const createNewTribe2 = await tribesNewContract.addNewTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        name2, ipfsHash, description
    );

    const event2 = await createNewTribe2.wait();
    console.log(event2.events[0].event)




    //joining a tribe and checking if they joined the right one (2 should be Merkle2)
    const joinTribe = await tribesNewContract.joinTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        2
    );

    const joinTxn = await joinTribe.wait();

    const getUserTribe = await tribesNewContract.getUserTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );
    console.log(joinTxn.events[0].event, ":",  hre.ethers.utils.parseBytes32String(getUserTribe))
 

   
    //we get totalTribes so we can iterate from IDs 1 to totalTribes and query the tribes info
    const tribeTotal = await tribesNewContract.totalTribes(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );
    const totalTribes = parseInt(Number(tribeTotal._hex), 10);

    console.log("Total of ", totalTribes, "tribes : ")
    for(let i=1; i<= totalTribes; ++i) {
        let txn = await tribesNewContract.getTribeData("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", i);
        console.log(
          hre.ethers.utils.parseBytes32String(txn[0]), 
        //    hre.ethers.utils.parseBytes32String(txn[1]),
        //   hre.ethers.utils.parseBytes32String(txn[2])
        );
    }


    //user leaves tribe
    const leave = await tribesNewContract.leaveTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    ); 
    const leaveTxn = await leave.wait()
    console.log(leaveTxn.events[0].event);


    //should throw an err not in tribe:
    const getUserTribe2 = await tribesNewContract.getUserTribe(
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );

    console.log(getUserTribe2)

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });