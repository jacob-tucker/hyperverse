import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import HFungibleToken from "../../../contracts/Hyperverse/HFungibleToken.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, id: UInt64, marketplace: Address) {

    let NFTCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    let Vault: @HFungibleToken.Vault
    let SaleCollection: &NFTMarketplace.SaleCollection{NFTMarketplace.SalePublic}

    prepare(signer: AuthAccount) {
        let Bundle = signer.borrow<&NFTMarketplace.Bundle>(from: NFTMarketplace.BundleStoragePath)
                        ?? panic("Could not borrow the signer's Bundle.")

        let SimpleNFTBundle = signer.getCapability(SimpleNFT.BundlePublicPath)
                                .borrow<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>()
                                ?? panic("Could not get the public Bundle.")

        self.NFTCollection = SimpleNFTBundle.borrowCollectionPublic(tenant: tenantOwner)

        let PublicBundle = getAccount(marketplace).getCapability(NFTMarketplace.BundlePublicPath)
                                .borrow<&NFTMarketplace.Bundle{NFTMarketplace.PublicBundle}>()
                                ?? panic("Could not get the public Bundle of the marketplace account.")

        self.SaleCollection = PublicBundle.borrowSaleCollectionPublic(tenant: tenantOwner)

        let SimpleTokenBundle = signer.borrow<&SimpleToken.Bundle>(from: SimpleToken.BundleStoragePath)
                                ?? panic("Could not get the public Bundle.")

        self.Vault <- SimpleTokenBundle.borrowVault(tenant: tenantOwner).withdraw(amount: self.SaleCollection.idPrice(id: id)!)
    }

    execute {
        self.SaleCollection.purchase(id: id, recipient: self.NFTCollection, buyTokens: <- self.Vault)
        log("Listed all the NFTs for Sale.")
    }
}

