import Marketplace from "../../../contracts/Project/Marketplace.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address) {

    let SaleCollection: &Marketplace.SaleCollection
    let NFTCollection: Capability<&SimpleNFT.Collection>

    prepare(signer: AuthAccount) {
        self.SaleCollection = signer.borrow<&Marketplace.SaleCollection>(from: Marketplace.SaleCollectionStoragePath)
                        ?? panic("Could not borrow the signer's Marketplace.SaleCollection")

        if !signer.getCapability<&SimpleNFT.Collection>(/private/SimpleNFTCollection).check() {
            signer.link<&SimpleNFT.Collection>(/private/SimpleNFTCollection, target: SimpleNFT.CollectionStoragePath)
        }
        self.NFTCollection = signer.getCapability<&SimpleNFT.Collection>(/private/SimpleNFTCollection)
    }

    execute {
        self.SaleCollection.addNFTCollection(tenantOwner, collection: self.NFTCollection)
    }
}