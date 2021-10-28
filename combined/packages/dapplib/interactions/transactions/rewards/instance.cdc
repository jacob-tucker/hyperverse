import Rewards from "../../../contracts/Project/Rewards.cdc"

transaction(tenantIDs: {String: UInt64}) {
    let RewardsPackage: &Rewards.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's Rewards.Package
        self.RewardsPackage = signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath)
                                ?? panic("Could not get the Rewards.Package from the signer.")
    }

    execute {
        tenantIDs.insert(key: "Rewards", self.RewardsPackage.uuid)
        self.RewardsPackage.instance(tenantIDs: tenantIDs)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}