import Rewards from "../../../contracts/Project/Rewards.cdc"

transaction() {
    let RewardsPackage: &Rewards.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's Rewards.Package
        self.RewardsPackage = signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath)
                                ?? panic("Could not get the Rewards.Package from the signer.")
    }

    execute {
        self.RewardsPackage.instance(tenantID: self.RewardsPackage.uuid)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}