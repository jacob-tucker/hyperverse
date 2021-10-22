import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

transaction() {
    let NFTMarketplacePackage: &NFTMarketplace.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's NFTMarketplace.Package
        self.NFTMarketplacePackage = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                                ?? panic("Could not get the NFTMarketplace.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        NFTMarketplace.instance(package: self.NFTMarketplacePackage)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}