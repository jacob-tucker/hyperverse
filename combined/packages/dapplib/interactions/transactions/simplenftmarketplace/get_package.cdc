import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import FlowToken from "../../../contracts/Flow/FlowToken.cdc"
import FungibleToken from "../../../contracts/Flow/FungibleToken.cdc"

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

        /* FlowToken */
        let FlowTokenVault = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

        /* SimpleNFTMarketplace */
        signer.save(<- SimpleNFTMarketplace.getPackage(SimpleNFTPackage: SimpleNFTPackage, FlowTokenVault: FlowTokenVault), to: SimpleNFTMarketplace.PackageStoragePath)
        signer.link<&SimpleNFTMarketplace.Package>(SimpleNFTMarketplace.PackagePrivatePath, target: SimpleNFTMarketplace.PackageStoragePath)
        signer.link<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>(SimpleNFTMarketplace.PackagePublicPath, target: SimpleNFTMarketplace.PackageStoragePath)
    }

    execute {
        log("Signer has a SimpleNFTMarketplace.Package.")
    }
}

