import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
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

        signer.save(<- SimpleNFT.createEmptyCollection(), to: /storage/SimpleNFTCollection)
        signer.link<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>(/public/SimpleNFTCollection, target: /storage/SimpleNFTCollection)
    }

    execute {
        log("Signer setup their Auth and all their Bundles for the 7 Smart Modules.")
    }
}

