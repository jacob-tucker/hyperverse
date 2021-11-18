import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import FlowToken from "../../../contracts/Flow/FlowToken.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, id: UInt64, marketplace: Address, simpleNFTTenantOwner: Address) {

    let NFTCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    let Vault: &FlowToken.Vault
    let SaleCollection: &SimpleNFTMarketplace.SaleCollection{SimpleNFTMarketplace.SalePublic}

    prepare(signer: AuthAccount) {
                        
        let Package = signer.borrow<&SimpleNFTMarketplace.Package>(from: SimpleNFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.NFTCollection = Package.SimpleNFTPackagePublic().borrowCollectionPublic(tenant: tenantOwner)

        let PackagePublic = getAccount(marketplace).getCapability(SimpleNFTMarketplace.PackagePublicPath)
                                .borrow<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>()
                                ?? panic("Could not get the public Package of the marketplace account.")

        self.SaleCollection = PackagePublic.borrowSaleCollectionPublic(tenant: tenantOwner)
        self.Vault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                        ?? panic("Could not borrow the FlowToken Vault")
    }

    execute {
        self.SaleCollection.purchase(simpleNFTTenant: simpleNFTTenantOwner, id: id, recipient: self.NFTCollection, buyTokens: <- self.Vault.withdraw(amount: self.SaleCollection.idPrice(simpleNFTTenant: simpleNFTTenantOwner, id: id)!))
        log("Listed all the NFTs for Sale.")
    }
}

