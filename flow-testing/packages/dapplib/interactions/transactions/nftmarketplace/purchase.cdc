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
        let Package = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")

        self.NFTCollection = Package.SimpleNFTPackagePublic().borrowCollectionPublic(tenant: tenantOwner)

        let PackagePublic = getAccount(marketplace).getCapability(NFTMarketplace.PackagePublicPath)
                                .borrow<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>()
                                ?? panic("Could not get the public Package of the marketplace account.")

        self.SaleCollection = PackagePublic.borrowSaleCollectionPublic(tenant: tenantOwner)
        self.Vault <- Package.SimpleTokenPackage.borrow()!.borrowVault(tenant: tenantOwner).withdraw(amount: self.SaleCollection.idPrice(id: id)!)
    }

    execute {
        self.SaleCollection.purchase(id: id, recipient: self.NFTCollection, buyTokens: <- self.Vault)
        log("Listed all the NFTs for Sale.")
    }
}

