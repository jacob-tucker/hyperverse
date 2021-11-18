import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address, tenantOwner: Address, name: String) {

    let SimpleNFTMinter: &SimpleNFT.NFTMinter
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {                    
        let SignerSimpleNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleNFT.Package.")

        self.SimpleNFTMinter = SignerSimpleNFTPackage.borrowMinter(tenant: tenantOwner)

        let RecipientSimpleNFTPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                            .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleNFT.Package.")
        self.RecipientCollection = RecipientSimpleNFTPackage.borrowCollectionPublic(tenant: tenantOwner)
    }

    execute {
        let nft <- self.SimpleNFTMinter.mintNFT(metadata: {"name": name}) 
        self.RecipientCollection.deposit(token: <-nft)
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

