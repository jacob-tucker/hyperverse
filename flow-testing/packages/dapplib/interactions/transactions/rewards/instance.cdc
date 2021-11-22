import Rewards from "../../../contracts/Project/Rewards.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction(numForReward: Int) {
    let Auth: &HyperverseAuth.Auth

    prepare(signer: AuthAccount) {
        self.Auth = signer.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)
                                ?? panic("Could not get the Auth from the signer.")
    }

    execute {
        Rewards.createTenant(auth: self.Auth, numForReward: numForReward)
        log("Create a new instance of a Rewards Tenant.")
    }
}
