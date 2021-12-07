import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction(initialSupply: UFix64) {
    let Auth: &HyperverseAuth.Auth

    prepare(signer: AuthAccount) {
        self.Auth = signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)
                                ?? panic("Could not get the Auth from the signer.")
    }

    execute {
        SimpleToken.createTenant(auth: self.Auth, initialSupply: initialSupply)
        log("Create a new instance of a SimpleToken Tenant.")
    }
}
