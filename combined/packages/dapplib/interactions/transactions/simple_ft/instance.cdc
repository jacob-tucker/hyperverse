import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction() {
    let SFTPackage: &SimpleFT.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's SimpleFT.Package
        self.SFTPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                ?? panic("Could not get the SimpleFT.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        let UID <- HyperverseModule.createUID()
        SimpleFT.instance(package: self.SFTPackage, uid: &UID as &HyperverseModule.UniqueID)
        destroy UID
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}