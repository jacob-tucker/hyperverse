import Rewards from "../../../contracts/Project/Rewards.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

transaction() {
    let RewardsPackage: &Rewards.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's Rewards.Package
        self.RewardsPackage = signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath)
                                ?? panic("Could not get the Rewards.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        Rewards.instance(package: self.RewardsPackage)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}