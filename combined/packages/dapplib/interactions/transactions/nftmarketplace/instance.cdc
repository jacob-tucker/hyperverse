import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction(modules: {String: UInt64}) {
    let NFTMarketplacePackage: &NFTMarketplace.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's NFTMarketplace.Package
        self.NFTMarketplacePackage = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                                ?? panic("Could not get the NFTMarketplace.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        self.NFTMarketplacePackage.instance(tenantID: self.NFTMarketplacePackage.uuid, modules: modules)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}