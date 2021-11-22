import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import FlowToken from "../../../contracts/Flow/FlowToken.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address, id: UInt64, marketplace: Address) {

    let NFTCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    let Vault: &FlowToken.Vault
    let SaleCollection: &SimpleNFTMarketplace.SaleCollection{SimpleNFTMarketplace.SalePublic}

    prepare(signer: AuthAccount) {
                        
        let Bundle = signer.borrow<&SimpleNFTMarketplace.Bundle>(from: SimpleNFTMarketplace.BundleStoragePath)
                        ?? panic("Could not borrow the signer's Bundle.")

        let SimpleNFTBundle = signer.getCapability(SimpleNFT.BundlePublicPath)
                                .borrow<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>()
                                ?? panic("Could not get the public Bundle.")

        self.NFTCollection = SimpleNFTBundle.borrowCollectionPublic(tenant: tenantOwner)

        let PublicBundle = getAccount(marketplace).getCapability(SimpleNFTMarketplace.BundlePublicPath)
                                .borrow<&SimpleNFTMarketplace.Bundle{SimpleNFTMarketplace.PublicBundle}>()
                                ?? panic("Could not get the public Bundle of the marketplace account.")

        self.SaleCollection = PublicBundle.borrowSaleCollectionPublic(tenant: tenantOwner)
        self.Vault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                        ?? panic("Could not borrow the FlowToken Vault")
    }

    execute {
        self.SaleCollection.purchase(id: id, recipient: self.NFTCollection, buyTokens: <- self.Vault.withdraw(amount: self.SaleCollection.idPrice(id: id)!))
        log("Listed all the NFTs for Sale.")
    }
}

