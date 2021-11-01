import Tribes from "../../../contracts/Project/Tribes.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction() {
    let Auth: &HyperverseAuth.Auth

    prepare(signer: AuthAccount) {
        self.Auth = signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)
                                ?? panic("Could not get the Auth from the signer.")
    }

    execute {
        Tribes.instance(auth: self.Auth, modules: {})
        log("Create a new instance of a Tribes Tenant.")
    }
}
