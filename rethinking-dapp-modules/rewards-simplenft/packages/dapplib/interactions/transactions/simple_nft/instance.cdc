import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

transaction() {
    let SNFTPackage: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's SimpleNFT.Package
        self.SNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                ?? panic("Could not get the SimpleNFT.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        SimpleNFT.instance(package: self.SNFTPackage)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}