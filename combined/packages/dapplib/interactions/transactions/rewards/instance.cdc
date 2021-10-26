import Rewards from "../../../contracts/Project/Rewards.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction() {
    let RewardsPackage: &Rewards.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's Rewards.Package
        self.RewardsPackage = signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath)
                                ?? panic("Could not get the Rewards.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        let UID <- HyperverseModule.createUID()
        Rewards.instance(package: self.RewardsPackage, uid: &UID as &HyperverseModule.UniqueID)
        destroy UID
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}