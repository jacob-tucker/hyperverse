import FlowMarketplace from "../../../contracts/Project/FlowMarketplace.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: String, ids: [UInt64], price: UFix64) {

    let SaleCollection: &FlowMarketplace.SaleCollection

    prepare(signer: AuthAccount) {

        let Package = signer.borrow<&FlowMarketplace.Package>(from: FlowMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.SaleCollection = Package.borrowSaleCollection(tenantID: tenantID)
    }

    execute {
        self.SaleCollection.listForSale(ids: ids, price: price)
        log("Listed all the NFTs for Sale.")
    }
}

