import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"
import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import Tribes from "../../../contracts/Project/Tribes.cdc"
import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import FlowToken from "../../../contracts/Flow/FlowToken.cdc"
import FungibleToken from "../../../contracts/Flow/FungibleToken.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

// Sets up all the Packages from the 5 Smart Modules for an account.
transaction() {

    prepare(signer: AuthAccount) {
        /* Auth */
        if signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath) == nil {
            signer.save(<- HyperverseAuth.createAuth(), to: HyperverseAuth.AuthStoragePath)
            signer.link<&HyperverseAuth.Auth{HyperverseAuth.IAuth}>(HyperverseAuth.AuthPublicPath, target: HyperverseAuth.AuthStoragePath)
            signer.link<&HyperverseAuth.Auth>(HyperverseAuth.AuthPrivatePath, target: HyperverseAuth.AuthStoragePath)
        }
        let auth = signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)
                        ?? panic("Could not borrow the Auth.")
        let authCapability = signer.getCapability<&HyperverseAuth.Auth>(HyperverseAuth.AuthPrivatePath)

        /* SimpleToken */
        if signer.borrow<&SimpleToken.Package>(from: SimpleToken.PackageStoragePath) == nil {
            signer.save(<- SimpleToken.getPackage(), to: SimpleToken.PackageStoragePath)
            signer.link<auth &SimpleToken.Package>(SimpleToken.PackagePrivatePath, target: SimpleToken.PackageStoragePath)
            signer.link<&SimpleToken.Package{SimpleToken.PackagePublic}>(SimpleToken.PackagePublicPath, target: SimpleToken.PackageStoragePath)
            auth.addPackage(packageName: SimpleToken.getType().identifier, packageRef: signer.getCapability<auth &IHyperverseComposable.Package>(SimpleToken.PackagePrivatePath))
        }

        /* SimpleNFT */
        if signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath) == nil {
            signer.save(<- SimpleNFT.getPackage(), to: SimpleNFT.PackageStoragePath)
            signer.link<auth &SimpleNFT.Package>(SimpleNFT.PackagePrivatePath, target: SimpleNFT.PackageStoragePath)
            signer.link<&SimpleNFT.Package{SimpleNFT.PackagePublic}>(SimpleNFT.PackagePublicPath, target: SimpleNFT.PackageStoragePath)
            auth.addPackage(packageName: SimpleNFT.getType().identifier, packageRef: signer.getCapability<auth &IHyperverseComposable.Package>(SimpleNFT.PackagePrivatePath))
        }

        /* Tribes */
        if signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath) == nil {
            signer.save(<- Tribes.getPackage(), to: Tribes.PackageStoragePath)
            signer.link<auth &Tribes.Package>(Tribes.PackagePrivatePath, target: Tribes.PackageStoragePath)
            signer.link<&Tribes.Package{Tribes.PackagePublic}>(Tribes.PackagePublicPath, target: Tribes.PackageStoragePath)
            auth.addPackage(packageName: Tribes.getType().identifier, packageRef: signer.getCapability<auth &IHyperverseComposable.Package>(Tribes.PackagePrivatePath))
        }

        /* Rewards */
        if signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath) == nil {
            let SimpleNFTPackage = signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath)
            signer.save(<- Rewards.getPackage(auth: authCapability), to: Rewards.PackageStoragePath)
            signer.link<auth &Rewards.Package>(Rewards.PackagePrivatePath, target: Rewards.PackageStoragePath)
            signer.link<&Rewards.Package{Rewards.PackagePublic}>(Rewards.PackagePublicPath, target: Rewards.PackageStoragePath)
            auth.addPackage(packageName: Rewards.getType().identifier, packageRef: signer.getCapability<auth &IHyperverseComposable.Package>(Rewards.PackagePrivatePath))
        }

        /* NFTMarketplace */
        if signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath) == nil {
            signer.save(<- NFTMarketplace.getPackage(auth: authCapability), to: NFTMarketplace.PackageStoragePath)
            signer.link<auth &NFTMarketplace.Package>(NFTMarketplace.PackagePrivatePath, target: NFTMarketplace.PackageStoragePath)
            signer.link<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>(NFTMarketplace.PackagePublicPath, target: NFTMarketplace.PackageStoragePath)
            auth.addPackage(packageName: NFTMarketplace.getType().identifier, packageRef: signer.getCapability<auth &IHyperverseComposable.Package>(NFTMarketplace.PackagePrivatePath))
        }

        /* SimpleNFTMarketplace */
        if signer.borrow<&SimpleNFTMarketplace.Package>(from: SimpleNFTMarketplace.PackageStoragePath) == nil {
            let FlowTokenVault = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            signer.save(<- SimpleNFTMarketplace.getPackage(auth: authCapability, FlowTokenVault: FlowTokenVault), to: SimpleNFTMarketplace.PackageStoragePath)
            signer.link<auth &SimpleNFTMarketplace.Package>(SimpleNFTMarketplace.PackagePrivatePath, target: SimpleNFTMarketplace.PackageStoragePath)
            signer.link<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>(SimpleNFTMarketplace.PackagePublicPath, target: SimpleNFTMarketplace.PackageStoragePath)
            auth.addPackage(packageName: SimpleNFTMarketplace.getType().identifier, packageRef: signer.getCapability<auth &IHyperverseComposable.Package>(SimpleNFTMarketplace.PackagePrivatePath))
        }
    }

    execute {
        log("Signer setup their Auth and all their Packages for the 6 Smart Modules.")
    }
}

