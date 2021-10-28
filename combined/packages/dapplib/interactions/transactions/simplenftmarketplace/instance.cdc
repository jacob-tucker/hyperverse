import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction(modules: {String: UInt64}) {
    let SimpleNFTMarketplacePackage: &SimpleNFTMarketplace.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's SimpleNFTMarketplace.Package
        self.SimpleNFTMarketplacePackage = signer.borrow<&SimpleNFTMarketplace.Package>(from: SimpleNFTMarketplace.PackageStoragePath)
                                ?? panic("Could not get the SimpleNFTMarketplace.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        self.SimpleNFTMarketplacePackage.instance(tenantID: self.SimpleNFTMarketplacePackage.uuid, modules: modules)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}