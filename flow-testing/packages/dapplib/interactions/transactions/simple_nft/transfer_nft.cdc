import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, withdrawID: UInt64, tenantOwner: Address) {

    let SignerCollection: &SimpleNFT.Collection
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {

        let SignerPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                ?? panic("Could not borrow the signer's SimpleNFT Package.")

        self.SignerCollection = SignerPackage.borrowCollection(tenant: tenantOwner)

        let RecipientPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                ?? panic("Could not borrow the recipient's public SimpleNFT Package.")

        self.RecipientCollection = RecipientPackage.borrowCollectionPublic(tenant: tenantOwner)
    }

    execute {
        self.RecipientCollection.deposit(token: <- self.SignerCollection.withdraw(withdrawID: withdrawID))
        log("Transferred a SimpleNFT from the signer into the recipient's SimpleNFT Collection.")
    }
}
