import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, withdrawID: UInt64, tenantOwner: Address) {

    let SignerCollection: &SimpleNFT.Collection
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {

        let SignerPackage = signer.borrow<&SimpleNFT.Bundle>(from: SimpleNFT.BundleStoragePath)
                                ?? panic("Could not borrow the signer's SimpleNFT Bundle.")

        self.SignerCollection = SignerPackage.borrowCollection(tenant: tenantOwner)

        let RecipientPackage = getAccount(recipient).getCapability(SimpleNFT.BundlePublicPath)
                                .borrow<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>()
                                ?? panic("Could not borrow the recipient's public SimpleNFT Bundle.")

        self.RecipientCollection = RecipientPackage.borrowCollectionPublic(tenant: tenantOwner)
    }

    execute {
        self.RecipientCollection.deposit(token: <- self.SignerCollection.withdraw(withdrawID: withdrawID))
        log("Transferred a SimpleNFT from the signer into the recipient's SimpleNFT Collection.")
    }
}
