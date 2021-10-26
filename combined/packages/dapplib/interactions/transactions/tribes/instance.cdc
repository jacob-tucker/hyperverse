import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction() {
    let TribesPackage: &Tribes.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's Tribes.Package
        self.TribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                ?? panic("Could not get the Tribes.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        self.TribesPackage.instance(tenantID: self.TribesPackage.uuid)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}