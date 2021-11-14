import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

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

        /* SimpleToken */
        if signer.getCapability<&SimpleToken.Package>(SimpleToken.PackagePrivatePath).borrow() == nil {
            signer.save(<- SimpleToken.getPackage(), to: SimpleToken.PackageStoragePath)
            signer.link<&SimpleToken.Package>(SimpleToken.PackagePrivatePath, target: SimpleToken.PackageStoragePath)
            signer.link<&SimpleToken.Package{SimpleToken.PackagePublic}>(SimpleToken.PackagePublicPath, target: SimpleToken.PackageStoragePath)
        }
        let SimpleTokenPackage = signer.getCapability<&SimpleToken.Package>(SimpleToken.PackagePrivatePath)

        /* NFTMarketplace */
        signer.save(<- NFTMarketplace.getPackage(SimpleNFTPackage: SimpleNFTPackage, SimpleTokenPackage: SimpleTokenPackage), to: NFTMarketplace.PackageStoragePath)
        signer.link<&NFTMarketplace.Package>(NFTMarketplace.PackagePrivatePath, target: NFTMarketplace.PackageStoragePath)
        signer.link<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>(NFTMarketplace.PackagePublicPath, target: NFTMarketplace.PackageStoragePath)
    }

    execute {
        log("Signer has a NFTMarketplace.Package.")
    }
}

