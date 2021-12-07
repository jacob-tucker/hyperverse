import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, tenantOwner: Address, name: String) {

    let SimpleNFTMinter: &SimpleNFT.Minter
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {                    

        self.SimpleNFTMinter = signer.borrow<&SimpleNFT.Minter>(from: SimpleNFT.MinterStoragePath)
                                    ?? panic("Could not borrow the SimpleNFT.Minter")

        self.RecipientCollection = getAccount(recipient).getCapability(SimpleNFT.CollectionPublicPath)
                                            .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleNFT.Collection.")
    }

    execute {
        let nft <- self.SimpleNFTMinter.mintNFT(tenant: tenantOwner, metadata: {"name": name}) 
        self.RecipientCollection.deposit(token: <-nft)
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

