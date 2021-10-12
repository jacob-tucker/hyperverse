import MorganNFT from "../../../contracts/Project/MorganNFT.cdc"
import NonFungibleToken from "../../../contracts/Flow/NonFungibleToken.cdc"
import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

transaction(recipient: Address, morganNFTTenantAccount: Address) {
    let morganNFTMinter: &MorganNFT.NFTMinter
    let recipientCollection: &MorganNFT.Collection{NonFungibleToken.CollectionPublic}
    let morganNFTTenantMinter: &MorganNFT.Tenant{MorganNFT.ITenantMinter}

    prepare(signer: AuthAccount) {
        let nftMarketplaceTenantPublic = getAccount(morganNFTTenantAccount).getCapability(NFTMarketplace.getMetadata().tenantPublicPath)
                        .borrow<&NFTMarketplace.Tenant{NFTMarketplace.ITenantPublic}>()
                        ?? panic("Could not borrow the signer's NFTMarketplace Tenant for Minting.")

        self.morganNFTTenantMinter = nftMarketplaceTenantPublic.morganNFTTenantMinter()

        self.morganNFTMinter = signer.borrow<&MorganNFT.NFTMinter>(from: /storage/MorganNFTMinter)
                                ?? panic("Could not borrow a MorganNFT Minter")

        self.recipientCollection = getAccount(recipient).getCapability(MorganNFT.CollectionPublicPath)
                                        .borrow<&MorganNFT.Collection{NonFungibleToken.CollectionPublic}>()
                                        ?? panic("Could not borrow the recipient's public MorganNFT Collection")
    }

    execute {
        self.morganNFTMinter.mintNFT(tenant: self.morganNFTTenantMinter, recipientCollection: self.recipientCollection)
        log("Minted a MorganNFT into the recipient's Collection.")
    }
}

