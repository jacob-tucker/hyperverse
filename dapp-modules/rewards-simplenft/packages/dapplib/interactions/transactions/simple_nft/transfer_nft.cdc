import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, withdrawID: UInt64, tenant: Address) {
    let SignerCollection: &SimpleNFT.Collection
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {
        let SimpleNFTTenant = getAccount(tenant).getCapability(SimpleNFT.getMetadata().tenantPublicPath)
                                    .borrow<&SimpleNFT.Tenant{SimpleNFT.IState}>()!

        let SignerPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                ?? panic("Could not borrow the signer's SimpleNFT Package.")

        self.SignerCollection = SignerPackage.borrowCollection(tenantID: SimpleNFTTenant.id)

        let RecipientPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                ?? panic("Could not borrow the recipient's public SimpleNFT Package.")

        self.RecipientCollection = RecipientPackage.borrowCollectionPublic(tenantID: SimpleNFTTenant.id)
    }

    execute {
        self.RecipientCollection.deposit(token: <- self.SignerCollection.withdraw(withdrawID: withdrawID))
        log("Transferred a SimpleNFT from the signer into the recipient's SimpleNFT Collection.")
    }
}
