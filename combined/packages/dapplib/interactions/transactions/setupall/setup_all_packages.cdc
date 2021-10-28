import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"
import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import Tribes from "../../../contracts/Project/Tribes.cdc"
import FlowMarketplace from "../../../contracts/Project/FlowMarketplace.cdc"
import FlowToken from "../../../contracts/Flow/FlowToken.cdc"
import FungibleToken from "../../../contracts/Flow/FungibleToken.cdc"

// Sets up all the Packages from the 5 Smart Modules for an account.
transaction() {

    prepare(signer: AuthAccount) {
        /* SimpleFT */
        if signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath) == nil {
            signer.save(<- SimpleFT.getPackage(), to: SimpleFT.PackageStoragePath)
            signer.link<&SimpleFT.Package>(SimpleFT.PackagePrivatePath, target: SimpleFT.PackageStoragePath)
            signer.link<&SimpleFT.Package{SimpleFT.PackagePublic}>(SimpleFT.PackagePublicPath, target: SimpleFT.PackageStoragePath)
        }

        /* SimpleNFT */
        if signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath) == nil {
            signer.save(<- SimpleNFT.getPackage(), to: SimpleNFT.PackageStoragePath)
            signer.link<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath, target: SimpleNFT.PackageStoragePath)
            signer.link<&SimpleNFT.Package{SimpleNFT.PackagePublic}>(SimpleNFT.PackagePublicPath, target: SimpleNFT.PackageStoragePath)
        }

        /* Tribes */
        if signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath) == nil {
            signer.save(<- Tribes.getPackage(), to: Tribes.PackageStoragePath)
            signer.link<&Tribes.Package>(Tribes.PackagePrivatePath, target: Tribes.PackageStoragePath)
            signer.link<&Tribes.Package{Tribes.PackagePublic}>(Tribes.PackagePublicPath, target: Tribes.PackageStoragePath)
        }

        /* Rewards */
        if signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath) == nil {
            let SimpleNFTPackage = signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath)
            signer.save(<- Rewards.getPackage(SimpleNFTPackage: SimpleNFTPackage), to: Rewards.PackageStoragePath)
            signer.link<&Rewards.Package>(Rewards.PackagePrivatePath, target: Rewards.PackageStoragePath)
            signer.link<&Rewards.Package{Rewards.PackagePublic}>(Rewards.PackagePublicPath, target: Rewards.PackageStoragePath)
        }

        /* NFTMarketplace */
        if signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath) == nil {
            let SimpleNFTPackage = signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath)
            let SimpleFTPackage = signer.getCapability<&SimpleFT.Package>(SimpleFT.PackagePrivatePath)
            signer.save(<- NFTMarketplace.getPackage(SimpleNFTPackage: SimpleNFTPackage, SimpleFTPackage: SimpleFTPackage), to: NFTMarketplace.PackageStoragePath)
            signer.link<&NFTMarketplace.Package>(NFTMarketplace.PackagePrivatePath, target: NFTMarketplace.PackageStoragePath)
            signer.link<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>(NFTMarketplace.PackagePublicPath, target: NFTMarketplace.PackageStoragePath)
        }

        /* NFTMarketplace */
        if signer.borrow<&FlowMarketplace.Package>(from: FlowMarketplace.PackageStoragePath) == nil {
            let SimpleNFTPackage = signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath)
            let FlowTokenVault = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            signer.save(<- FlowMarketplace.getPackage(SimpleNFTPackage: SimpleNFTPackage, FlowTokenVault: FlowTokenVault), to: FlowMarketplace.PackageStoragePath)
            signer.link<&FlowMarketplace.Package>(FlowMarketplace.PackagePrivatePath, target: FlowMarketplace.PackageStoragePath)
            signer.link<&FlowMarketplace.Package{FlowMarketplace.PackagePublic}>(FlowMarketplace.PackagePublicPath, target: FlowMarketplace.PackageStoragePath)
        }
    }

    execute {
        log("Signer setup all their Packages for the 5 Smart Modules.")
    }
}

