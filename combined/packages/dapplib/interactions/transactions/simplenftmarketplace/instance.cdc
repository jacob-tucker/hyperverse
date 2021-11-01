import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction(modules: {String: Int}) {
    let Auth: &HyperverseAuth.Auth

    prepare(signer: AuthAccount) {
        self.Auth = signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)
                                ?? panic("Could not get the Auth from the signer.")
    }

    execute {
        SimpleNFTMarketplace.instance(auth: self.Auth, modules: modules)
        log("Create a new instance of a SimpleNFTMarketplace Tenant.")
    }
}
