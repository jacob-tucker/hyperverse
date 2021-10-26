import SimpleFT from 0x26a365de6d6237cd

transaction(tenantID: String, recipient: Address) {

    let AdminsSNFTPackage: &SimpleFT.Package
    let RecipientsSNFTPackage: &SimpleFT.Package{SimpleFT.PackagePublic}
    
    prepare(tenantOwner: AuthAccount) {

        let TenantPackage = getAccount(tenantOwner.address).getCapability(SimpleFT.PackagePublicPath)
                                .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")

        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleFT.PackagePublicPath)
                                        .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                        ?? panic("Could not borrow the public SimpleFT.Package from the recipient.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenantID: tenantID).createNewMinter()
        )
        log("Gave a SimpleFT.NFTMinter to the recipient's account.")
    }
}

