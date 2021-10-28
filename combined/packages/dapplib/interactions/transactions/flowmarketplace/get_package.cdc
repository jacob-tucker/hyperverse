import FlowMarketplace from "../../../contracts/Project/FlowMarketplace.cdc"
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

        /* FlowMarketplace */
        signer.save(<- FlowMarketplace.getPackage(SimpleNFTPackage: SimpleNFTPackage, FlowTokenVault: FlowTokenVault), to: FlowMarketplace.PackageStoragePath)
        signer.link<&FlowMarketplace.Package>(FlowMarketplace.PackagePrivatePath, target: FlowMarketplace.PackageStoragePath)
        signer.link<&FlowMarketplace.Package{FlowMarketplace.PackagePublic}>(FlowMarketplace.PackagePublicPath, target: FlowMarketplace.PackageStoragePath)
    }

    execute {
        log("Signer has a FlowMarketplace.Package.")
    }
}

