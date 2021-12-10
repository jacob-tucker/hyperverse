import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import Tribes from "../../../contracts/Project/Tribes.cdc"
import Marketplace from "../../../contracts/Project/Marketplace.cdc"
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

        signer.save(<- SimpleNFT.createEmptyCollection(), to: SimpleNFT.CollectionStoragePath)
        signer.link<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>(SimpleNFT.CollectionPublicPath, target: SimpleNFT.CollectionStoragePath)
    
        signer.save(<- SimpleToken.createEmptyVault(), to: SimpleToken.VaultStoragePath)
        signer.link<&SimpleToken.Vault{SimpleToken.VaultPublic}>(SimpleToken.VaultPublicPath, target: SimpleToken.VaultStoragePath)
    
        signer.save(<- Tribes.createIdentity(), to: Tribes.IdentityStoragePath)
        signer.link<&Tribes.Identity{Tribes.IdentityPublic}>(Tribes.IdentityPublicPath, target: Tribes.IdentityStoragePath)
    
        let ftVault = getAccount(signer.address).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        signer.save(<- Marketplace.createSaleCollection(ftVault: ftVault), to: Marketplace.SaleCollectionStoragePath)
        signer.link<&Marketplace.SaleCollection{Marketplace.SalePublic}>(Marketplace.SaleCollectionPublicPath, target: Marketplace.SaleCollectionStoragePath)
    }

    execute {
        log("Signer setup their Auth and all their Bundles for the 7 Smart Modules.")
    }
}

