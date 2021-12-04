const hre = require("hardhat");
async function main() {
    const TribeState = await hre.ethers.getContractFactory('TribesState');
    const TribeStateContract = await TribeState.deploy();
    await TribeStateContract.deployed() 
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });