import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, ids: [UInt64], price: UFix64) {

    let SaleCollection: &SimpleNFTMarketplace.SaleCollection

    prepare(signer: AuthAccount) {
        let Bundle = signer.borrow<&SimpleNFTMarketplace.Bundle>(from: SimpleNFTMarketplace.BundleStoragePath)
                        ?? panic("Could not borrow the signer's Bundle.")

        self.SaleCollection = Bundle.borrowSaleCollection(tenant: tenantOwner)
    }

    execute {           
        self.SaleCollection.listForSale(ids: ids, price: price)
        log("Listed all the NFTs for Sale.")
    }
}

