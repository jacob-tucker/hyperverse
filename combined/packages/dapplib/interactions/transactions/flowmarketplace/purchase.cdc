import FlowMarketplace from "../../../contracts/Project/FlowMarketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import FlowToken from "../../../contracts/Flow/FlowToken.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: String, id: UInt64, marketplace: Address) {

    let NFTCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    let Vault: &FlowToken.Vault
    let SaleCollection: &FlowMarketplace.SaleCollection{FlowMarketplace.SalePublic}

    prepare(signer: AuthAccount) {

        let Package = signer.borrow<&FlowMarketplace.Package>(from: FlowMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.NFTCollection = Package.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: tenantID)

        let PackagePublic = getAccount(marketplace).getCapability(FlowMarketplace.PackagePublicPath)
                                .borrow<&FlowMarketplace.Package{FlowMarketplace.PackagePublic}>()
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

