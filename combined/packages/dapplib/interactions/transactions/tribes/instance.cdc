import Tribes from "../../../contracts/Project/Tribes.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

transaction() {
    let TribesPackage: &Tribes.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's Tribes.Package
        self.TribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                ?? panic("Could not get the Tribes.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        Tribes.instance(package: self.TribesPackage)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}