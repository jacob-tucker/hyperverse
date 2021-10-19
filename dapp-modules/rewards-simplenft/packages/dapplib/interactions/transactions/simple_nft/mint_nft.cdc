import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, tenant: Address, name: String) {
    let SimpleNFTMinter: &SimpleNFT.NFTMinter
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {
        let SimpleNFTTenant = getAccount(tenant).getCapability(SimpleNFT.getMetadata().tenantPublicPath)
                                    .borrow<&SimpleNFT.Tenant{SimpleNFT.IState}>()!

        let SignerSimpleNFTPackage = signer.borrow<&SimpleNFT.Package>(from: /storage/SimpleNFTPackage)
                                    ?? panic("Could not borrow the signer's SimpleNFT.Package.")
        self.SimpleNFTMinter = SignerSimpleNFTPackage.borrowMinter(tenantID: SimpleNFTTenant.id)

        let RecipientSimpleNFTPackage = getAccount(recipient).getCapability(/public/SimpleNFTPackage)
                                            .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleNFT.Package.")
        self.RecipientCollection = RecipientSimpleNFTPackage.borrowCollectionPublic(tenantID: SimpleNFTTenant.id)
    }

    execute {
        let nft <- self.SimpleNFTMinter.mintNFT(name: name) 
        self.RecipientCollection.deposit(token: <-nft)
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

