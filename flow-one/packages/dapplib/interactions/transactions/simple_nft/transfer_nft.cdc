import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(id: UInt64, recipient: Address, tenantOwner: Address) {
    prepare(signer: AuthAccount) {
        let signerCollection = signer.borrow<&SimpleNFT.Collection>(from: SimpleNFT.CollectionStoragePath)
                                    ?? panic("Could not borrow the signer's SimpleNFT.Collection.")

        let recipientCollection = getAccount(recipient).getCapability(SimpleNFT.CollectionPublicPath)
                                    .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()
                                    ?? panic("Could not borrow the recipient's SimpleNFT.Collection")

        recipientCollection.deposit(token: <- signerCollection.withdraw(tenant: tenantOwner, withdrawID: id))
    }

    execute {
        log("Transfered the NFT from the signer to the recipient.")
    }
}