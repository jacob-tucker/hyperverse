import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, tenant: Address, name: String) {
    let SimpleNFTTenant: &SimpleNFT.Tenant{SimpleNFT.IState}
    let SimpleNFTMinter: &SimpleNFT.NFTMinter
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.SimpleNFTTenant = getAccount(tenant).getCapability(SimpleNFT.getMetadata().tenantPublicPath)
                                    .borrow<&SimpleNFT.Tenant{SimpleNFT.IState}>()!
        self.SimpleNFTMinter = signer.borrow<&SimpleNFT.NFTMinter>(from: /storage/SimpleNFTMinter)
                                    ?? panic("Could not borrow the SimpleNFT.NFTMinter.")

        self.RecipientCollection = getAccount(recipient).getCapability(SimpleNFT.CollectionPublicPath)
                                        .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()
                                        ?? panic("Could not borrow the recipient's public SimpleNFT Collection")
    }

    execute {
        let nft <- self.SimpleNFTMinter.mintNFT(tenant: self.SimpleNFTTenant, name: name)
        self.RecipientCollection.deposit(token: <-nft)
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

