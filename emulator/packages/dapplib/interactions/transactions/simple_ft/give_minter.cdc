import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address) {

    let TenantID: String
    let AdminsSNFTPackage: &SimpleToken.Package
    let RecipientsSNFTPackage: &SimpleToken.Package{SimpleToken.PackagePublic}
    
    prepare(tenantOwner: AuthAccount) {
        self.TenantID = tenantOwner.address.toString()
                        .concat(".")
                        .concat(SimpleToken.getType().identifier)

        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleToken.Package>(from: SimpleToken.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleToken.Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleToken.PackagePublicPath)
                                        .borrow<&SimpleToken.Package{SimpleToken.PackagePublic}>()
                                        ?? panic("Could not borrow the public SimpleToken.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenantID: self.TenantID).createNewMinter()
        )
        log("Gave a SimpleToken.NFTMinter to the recipient's account.")
    }
}

