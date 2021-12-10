import Marketplace from "../../../contracts/Project/Marketplace.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, ids: [UInt64], price: UFix64) {

    let SaleCollection: &Marketplace.SaleCollection

    prepare(signer: AuthAccount) {
        self.SaleCollection = signer.borrow<&Marketplace.SaleCollection>(from: Marketplace.SaleCollectionStoragePath)
                        ?? panic("Could not borrow the signer's Marketplace.SaleCollection")
    }

    execute {
        self.SaleCollection.listForSale(tenantOwner, ids: ids, price: price)
        log("Listed all the NFTs for Sale.")
    }
}