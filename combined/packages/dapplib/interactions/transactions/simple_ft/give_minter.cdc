import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(tenantID: String) {

    let AdminsSNFTPackage: &SimpleFT.Package
    let RecipientsSNFTPackage: &SimpleFT.Package
    
    prepare(tenantOwner: AuthAccount, recipient: AuthAccount) {

        let TenantPackage = getAccount(tenantOwner.address).getCapability(SimpleFT.PackagePublicPath)
                                .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")

        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")

        self.RecipientsSNFTPackage = recipient.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenantID: tenantID).createNewMinter()
        )
        log("Gave a SimpleFT.NFTMinter to the recipient's account.")
    }
}

