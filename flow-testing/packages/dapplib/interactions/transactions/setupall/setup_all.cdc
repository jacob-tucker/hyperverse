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

// Sets up all the Bundles from the 5 Smart Modules for an account.
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
        if signer.borrow<&SimpleToken.Bundle>(from: SimpleToken.BundleStoragePath) == nil {
            signer.save(<- SimpleToken.getBundle(), to: SimpleToken.BundleStoragePath)
            signer.link<auth &SimpleToken.Bundle>(SimpleToken.BundlePrivatePath, target: SimpleToken.BundleStoragePath)
            signer.link<&SimpleToken.Bundle{SimpleToken.PublicBundle}>(SimpleToken.BundlePublicPath, target: SimpleToken.BundleStoragePath)
            auth.addBundle(bundleName: SimpleToken.getType().identifier, bundle: signer.getCapability<auth &IHyperverseComposable.Bundle>(SimpleToken.BundlePrivatePath))
        }

        /* SimpleNFT */
        if signer.borrow<&SimpleNFT.Bundle>(from: SimpleNFT.BundleStoragePath) == nil {
            signer.save(<- SimpleNFT.getBundle(), to: SimpleNFT.BundleStoragePath)
            signer.link<auth &SimpleNFT.Bundle>(SimpleNFT.BundlePrivatePath, target: SimpleNFT.BundleStoragePath)
            signer.link<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>(SimpleNFT.BundlePublicPath, target: SimpleNFT.BundleStoragePath)
            auth.addBundle(bundleName: SimpleNFT.getType().identifier, bundle: signer.getCapability<auth &IHyperverseComposable.Bundle>(SimpleNFT.BundlePrivatePath))
        }

        /* Tribes */
        if signer.borrow<&Tribes.Bundle>(from: Tribes.BundleStoragePath) == nil {
            signer.save(<- Tribes.getBundle(), to: Tribes.BundleStoragePath)
            signer.link<auth &Tribes.Bundle>(Tribes.BundlePrivatePath, target: Tribes.BundleStoragePath)
            signer.link<&Tribes.Bundle{Tribes.PublicBundle}>(Tribes.BundlePublicPath, target: Tribes.BundleStoragePath)
            auth.addBundle(bundleName: Tribes.getType().identifier, bundle: signer.getCapability<auth &IHyperverseComposable.Bundle>(Tribes.BundlePrivatePath))
        }

        /* Rewards */
        if signer.borrow<&Rewards.Bundle>(from: Rewards.BundleStoragePath) == nil {
            signer.save(<- Rewards.getBundle(auth: authCapability), to: Rewards.BundleStoragePath)
            signer.link<auth &Rewards.Bundle>(Rewards.BundlePrivatePath, target: Rewards.BundleStoragePath)
            signer.link<&Rewards.Bundle{Rewards.PublicBundle}>(Rewards.BundlePublicPath, target: Rewards.BundleStoragePath)
            auth.addBundle(bundleName: Rewards.getType().identifier, bundle: signer.getCapability<auth &IHyperverseComposable.Bundle>(Rewards.BundlePrivatePath))
        }

        /* NFTMarketplace */
        if signer.borrow<&NFTMarketplace.Bundle>(from: NFTMarketplace.BundleStoragePath) == nil {
            signer.save(<- NFTMarketplace.getBundle(auth: authCapability), to: NFTMarketplace.BundleStoragePath)
            signer.link<auth &NFTMarketplace.Bundle>(NFTMarketplace.BundlePrivatePath, target: NFTMarketplace.BundleStoragePath)
            signer.link<&NFTMarketplace.Bundle{NFTMarketplace.PublicBundle}>(NFTMarketplace.BundlePublicPath, target: NFTMarketplace.BundleStoragePath)
            auth.addBundle(bundleName: NFTMarketplace.getType().identifier, bundle: signer.getCapability<auth &IHyperverseComposable.Bundle>(NFTMarketplace.BundlePrivatePath))
        }

        /* SimpleNFTMarketplace */
        if signer.borrow<&SimpleNFTMarketplace.Bundle>(from: SimpleNFTMarketplace.BundleStoragePath) == nil {
            let FlowTokenVault = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            signer.save(<- SimpleNFTMarketplace.getBundle(auth: authCapability, FlowTokenVault: FlowTokenVault), to: SimpleNFTMarketplace.BundleStoragePath)
            signer.link<auth &SimpleNFTMarketplace.Bundle>(SimpleNFTMarketplace.BundlePrivatePath, target: SimpleNFTMarketplace.BundleStoragePath)
            signer.link<&SimpleNFTMarketplace.Bundle{SimpleNFTMarketplace.PublicBundle}>(SimpleNFTMarketplace.BundlePublicPath, target: SimpleNFTMarketplace.BundleStoragePath)
            auth.addBundle(bundleName: SimpleNFTMarketplace.getType().identifier, bundle: signer.getCapability<auth &IHyperverseComposable.Bundle>(SimpleNFTMarketplace.BundlePrivatePath))
        }
    }

    execute {
        log("Signer setup their Auth and all their Bundles for the 7 Smart Modules.")
    }
}

