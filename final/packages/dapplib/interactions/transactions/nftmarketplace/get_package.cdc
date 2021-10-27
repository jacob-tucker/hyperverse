import NFTMarketplace from 0x26a365de6d6237cd
import SimpleNFT from 0x26a365de6d6237cd
import SimpleFT from 0x26a365de6d6237cd

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

        /* SimpleFT */
        if signer.getCapability<&SimpleFT.Package>(SimpleFT.PackagePrivatePath).borrow() == nil {
            signer.save(<- SimpleFT.getPackage(), to: SimpleFT.PackageStoragePath)
            signer.link<&SimpleFT.Package>(SimpleFT.PackagePrivatePath, target: SimpleFT.PackageStoragePath)
            signer.link<&SimpleFT.Package{SimpleFT.PackagePublic}>(SimpleFT.PackagePublicPath, target: SimpleFT.PackageStoragePath)
        }
        let SimpleFTPackage = signer.getCapability<&SimpleFT.Package>(SimpleFT.PackagePrivatePath)

        /* NFTMarketplace */
        signer.save(<- NFTMarketplace.getPackage(SimpleNFTPackage: SimpleNFTPackage, SimpleFTPackage: SimpleFTPackage), to: NFTMarketplace.PackageStoragePath)
        signer.link<&NFTMarketplace.Package>(NFTMarketplace.PackagePrivatePath, target: NFTMarketplace.PackageStoragePath)
        signer.link<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>(NFTMarketplace.PackagePublicPath, target: NFTMarketplace.PackageStoragePath)
    }

    execute {
        log("Signer has a NFTMarketplace.Package.")
    }
}

