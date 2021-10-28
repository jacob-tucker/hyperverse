import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(tenantIDs: {String: UInt64}) {
    let SNFTPackage: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's SimpleNFT.Package
        self.SNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                ?? panic("Could not get the SimpleNFT.Package from the signer.")
    }

    execute {
        tenantIDs.insert(key: "SimpleNFT", self.SNFTPackage.uuid)
        self.SNFTPackage.instance(tenantIDs: tenantIDs)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}