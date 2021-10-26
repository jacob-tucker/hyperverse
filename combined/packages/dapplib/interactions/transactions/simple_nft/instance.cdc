import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction() {
    let SNFTPackage: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's SimpleNFT.Package
        self.SNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                ?? panic("Could not get the SimpleNFT.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        let UID <- HyperverseModule.createUID()
        SimpleNFT.instance(package: self.SNFTPackage, uid: &UID as &HyperverseModule.UniqueID)
        destroy UID
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}