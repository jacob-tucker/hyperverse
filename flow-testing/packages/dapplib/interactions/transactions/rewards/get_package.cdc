import Rewards from "../../../contracts/Project/Rewards.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// THIS IS THE FIRST THING YOU RUN - EVEN BEFORE GETTING A TENANT IN 'instance.cdc'
// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        /* SimpleNFT */
        if signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath).borrow() == nil {
            signer.save(<- SimpleNFT.getPackage(), to: SimpleNFT.PackageStoragePath)
            signer.link<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath, target: SimpleNFT.PackageStoragePath)
            signer.link<&SimpleNFT.Package{SimpleNFT.PackagePublic}>(SimpleNFT.PackagePublicPath, target: SimpleNFT.PackageStoragePath)
        }
        let SimpleNFTPackage = signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath)

        /* Rewards */
        signer.save(<- Rewards.getPackage(SimpleNFTPackage: SimpleNFTPackage), to: Rewards.PackageStoragePath)
        signer.link<&Rewards.Package>(Rewards.PackagePrivatePath, target: Rewards.PackageStoragePath)
        signer.link<&Rewards.Package{Rewards.PackagePublic}>(Rewards.PackagePublicPath, target: Rewards.PackageStoragePath)
    }

    execute {
        log("Signer has a Rewards.Package.")
    }
}

