import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction() {
    let Auth: &HyperverseAuth.Auth

    prepare(signer: AuthAccount) {
        self.Auth = signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)
                                ?? panic("Could not get the Auth from the signer.")
    }

    execute {
        SimpleNFT.instance(auth: self.Auth)
        log("Create a new instance of a SimpleNFT Tenant.")
    }
}
