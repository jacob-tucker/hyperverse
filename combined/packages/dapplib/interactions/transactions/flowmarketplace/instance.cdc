import FlowMarketplace from "../../../contracts/Project/FlowMarketplace.cdc"
import HyperverseModule from "../../../contracts/Hyperverse/HyperverseModule.cdc"

transaction(SimpleNFTID: UInt64?) {
    let FlowMarketplacePackage: &FlowMarketplace.Package

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's FlowMarketplace.Package
        self.FlowMarketplacePackage = signer.borrow<&FlowMarketplace.Package>(from: FlowMarketplace.PackageStoragePath)
                                ?? panic("Could not get the FlowMarketplace.Package from the signer.")
    }

    execute {
        // Create a new instance of a Tenant using your Package as a key.
        self.FlowMarketplacePackage.instance(tenantID: self.FlowMarketplacePackage.uuid, SimpleNFTID: SimpleNFTID)
        log("Create a new instance of a Tenant using your Package as a key.")
    }
}