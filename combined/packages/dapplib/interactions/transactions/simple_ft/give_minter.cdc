import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(tenantID: String, recipient: Address) {

    let AdminsSNFTPackage: &SimpleFT.Package
    let RecipientsSNFTPackage: &SimpleFT.Package{SimpleFT.PackagePublic}
    
    prepare(tenantOwner: AuthAccount) {

        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleFT.PackagePublicPath)
                                        .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                        ?? panic("Could not borrow the public SimpleFT.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenantID: tenantID).createNewMinter()
        )
        log("Gave a SimpleFT.NFTMinter to the recipient's account.")
    }
}

