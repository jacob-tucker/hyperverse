import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(recipient: Address) {

    let TenantID: String
    let AdminsSNFTPackage: &SimpleFT.Package
    let RecipientsSNFTPackage: &SimpleFT.Package{SimpleFT.PackagePublic}
    
    prepare(tenantOwner: AuthAccount) {
        self.TenantID = tenantOwner.address.toString()
                        .concat(".")
                        .concat(SimpleFT.getType().identifier)

        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleFT.PackagePublicPath)
                                        .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                        ?? panic("Could not borrow the public SimpleFT.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenantID: self.TenantID).createNewMinter()
        )
        log("Gave a SimpleFT.NFTMinter to the recipient's account.")
    }
}

