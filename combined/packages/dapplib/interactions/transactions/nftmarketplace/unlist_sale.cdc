import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, id: UInt64) {

    let TenantID: String
    let SaleCollection: &NFTMarketplace.SaleCollection

    prepare(signer: AuthAccount) {
        let TenantPackage = getAccount(tenantOwner).getCapability(NFTMarketplace.PackagePublicPath)
                                .borrow<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

        let Package = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.SaleCollection = Package.borrowSaleCollection(tenantID: self.TenantID)
    }

    execute {
        self.SaleCollection.unlistSale(id: id)
        log("Unlisted the NFT with id from Sale.")
    }
}

