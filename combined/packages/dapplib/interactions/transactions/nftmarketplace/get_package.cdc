import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

// THIS IS THE FIRST THING YOU RUN - EVEN BEFORE GETTING A TENANT IN 'instance.cdc'
// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        let SimpleNFTPackage = signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath)
        let SimpleFTPackage = signer.getCapability<&SimpleFT.Package>(SimpleFT.PackagePrivatePath)
        signer.save(<- NFTMarketplace.getPackage(SimpleNFTPackage: SimpleNFTPackage, SimpleFTPackage: SimpleFTPackage), to: NFTMarketplace.PackageStoragePath)
        signer.link<&NFTMarketplace.Package>(NFTMarketplace.PackagePrivatePath, target: NFTMarketplace.PackageStoragePath)
        signer.link<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>(NFTMarketplace.PackagePublicPath, target: NFTMarketplace.PackageStoragePath)
    }

    execute {
        log("Signer has a NFTMarketplace.Package.")
    }
}

