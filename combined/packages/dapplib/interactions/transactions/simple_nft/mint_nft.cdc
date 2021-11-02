import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, tenantOwner: Address, name: String) {

    let TenantID: String
    let SimpleNFTMinter: &SimpleNFT.NFTMinter
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleNFT.getType().identifier)
                        .concat(".0")
        let SignerSimpleNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleNFT.Package.")

        self.SimpleNFTMinter = SignerSimpleNFTPackage.borrowMinter(tenantID: self.TenantID)

        let RecipientSimpleNFTPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                            .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleNFT.Package.")
        self.RecipientCollection = RecipientSimpleNFTPackage.borrowCollectionPublic(tenantID: self.TenantID)
    }

    execute {
        let nft <- self.SimpleNFTMinter.mintNFT(metadata: {"name": name}) 
        self.RecipientCollection.deposit(token: <-nft)
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

