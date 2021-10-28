import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(tenantIDs: {String: UInt64}) {
    let SFTPackage: &SimpleFT.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's SimpleFT.Package
        self.SFTPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                ?? panic("Could not get the SimpleFT.Package from the signer.")
    }

    execute {
        tenantIDs.insert(key: "SimpleFT", self.SFTPackage.uuid)
        self.SFTPackage.instance(tenantIDs: tenantIDs)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}