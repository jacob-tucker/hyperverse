import Tribes from "../../../contracts/Project/Tribes.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction() {
    let TribesPackage: &Tribes.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's Tribes.Package
        self.TribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                ?? panic("Could not get the Tribes.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        let UID <- HyperverseModule.createUID()
        Tribes.instance(package: self.TribesPackage, uid: &UID as &HyperverseModule.UniqueID)
        destroy UID
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}