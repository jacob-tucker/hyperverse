import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction() {
    let SNFTPackage: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's SimpleNFT.Package
        self.SNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                ?? panic("Could not get the SimpleNFT.Package from the signer.")
    }

    execute {
        self.SNFTPackage.instance(tenantID: self.SNFTPackage.uuid)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}