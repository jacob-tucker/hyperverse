import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction() {

    let TenantID: String
    let AdminsSNFTPackage: &SimpleFT.Package
    let RecipientsSNFTPackage: &SimpleFT.Package
    
    prepare(tenantOwner: AuthAccount, recipient: AuthAccount) {

        let TenantPackage = getAccount(tenantOwner.address).getCapability(SimpleFT.PackagePublicPath)
                                .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")

        self.TenantID = tenantOwner.address.toString().concat(".").concat(TenantPackage.uuid.toString())

        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")

        self.RecipientsSNFTPackage = recipient.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenantID: self.TenantID).createNewMinter()
        )
        log("Gave a SimpleFT.NFTMinter to the recipient's account.")
    }
}

