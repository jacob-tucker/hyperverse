import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import FlowToken from "../../../contracts/Flow/FlowToken.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: String, id: UInt64, marketplace: Address) {

    let NFTCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    let Vault: &FlowToken.Vault
    let SaleCollection: &SimpleNFTMarketplace.SaleCollection{SimpleNFTMarketplace.SalePublic}

    prepare(signer: AuthAccount) {

        let Package = signer.borrow<&SimpleNFTMarketplace.Package>(from: SimpleNFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.NFTCollection = Package.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: tenantID)

        let PackagePublic = getAccount(marketplace).getCapability(SimpleNFTMarketplace.PackagePublicPath)
                                .borrow<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>()
                                ?? panic("Could not get the public Package of the marketplace account.")

        self.SaleCollection = PackagePublic.borrowSaleCollectionPublic(tenantID: tenantID)
        self.Vault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                        ?? panic("Could not borrow the FlowToken Vault")
    }

    execute {

        self.SaleCollection.purchase(id: id, recipient: self.NFTCollection, buyTokens: <- self.Vault.withdraw(amount: self.SaleCollection.idPrice(id: id)!))
        log("Listed all the NFTs for Sale.")
    }
}

