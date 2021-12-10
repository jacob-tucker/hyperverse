import Marketplace from "../../../contracts/Project/Marketplace.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction() {
    let Auth: &HyperverseAuth.Auth

    prepare(signer: AuthAccount) {
        self.Auth = signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)
                                ?? panic("Could not get the Auth from the signer.")
    }

    execute {
        Marketplace.createTenant(auth: self.Auth, type: Type<@SimpleNFT.Collection>())
        log("Create a new instance of a Marketplace Tenant.")
    }
}
