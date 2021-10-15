import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, withdrawID: UInt64) {
    let SignerCollection: &SimpleNFT.Collection
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.RecipientCollection = getAccount(recipient).getCapability(SimpleNFT.CollectionPublicPath)
                                        .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()
                                        ?? panic("Could not borrow the recipient's public SimpleNFT Collection")

        self.SignerCollection = signer.borrow<&SimpleNFT.Collection>(from: SimpleNFT.CollectionStoragePath)
                                    ?? panic("Could not borrow the signer's SimpleNFT Collection.")
    }

    execute {
        let nft <- self.SignerCollection.withdraw(withdrawID: withdrawID)
        self.RecipientCollection.deposit(token: <-nft)
        log("Transferred a SimpleNFT from the signer into the recipient's SimpleNFT Collection.")
    }
}

