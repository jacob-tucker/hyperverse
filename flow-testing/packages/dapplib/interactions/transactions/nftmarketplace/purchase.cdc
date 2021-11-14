import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, id: UInt64, marketplace: Address) {

    let TenantID: String
    let NFTCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    let Vault: @SimpleToken.Vault
    let SaleCollection: &NFTMarketplace.SaleCollection{NFTMarketplace.SalePublic}

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(NFTMarketplace.getType().identifier)

        let Package = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.NFTCollection = Package.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: self.TenantID)

        let PackagePublic = getAccount(marketplace).getCapability(NFTMarketplace.PackagePublicPath)
                                .borrow<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>()
                                ?? panic("Could not get the public Package of the marketplace account.")

        self.SaleCollection = PackagePublic.borrowSaleCollectionPublic(tenantID: self.TenantID)
        self.Vault <- Package.SimpleTokenPackage.borrow()!.borrowVault(tenantID: self.TenantID).withdraw(amount: self.SaleCollection.idPrice(id: id)!)
    }

    execute {

        self.SaleCollection.purchase(id: id, recipient: self.NFTCollection, buyTokens: <- self.Vault)
        log("Listed all the NFTs for Sale.")
    }
}

