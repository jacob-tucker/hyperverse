import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, tenantOwner: Address, name: String) {

    let SimpleNFTMinter: &SimpleNFT.NFTMinter
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {                    

        self.SimpleNFTMinter = signer.borrow<&SimpleNFT.NFTMinter>(from: /storage/SimpleNFTMinter)!

        self.RecipientCollection = getAccount(recipient).getCapability(/public/SimpleNFTCollection)
                                            .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleNFTCollection.")
    }

    execute {
        let nft <- self.SimpleNFTMinter.mintNFT(tenant: tenantOwner, metadata: {"name": name}) 
        self.RecipientCollection.deposit(tenant: tenantOwner, token: <-nft)
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

