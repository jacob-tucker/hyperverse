import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address) {

    let Tenant: Address
    let AdminsSNFTPackage: &SimpleToken.Package
    let RecipientsSNFTPackage: &SimpleToken.Package{SimpleToken.PackagePublic}
    
    prepare(tenantOwner: AuthAccount) {
        self.Tenant = tenantOwner.address
        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleToken.Package>(from: SimpleToken.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleToken.Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleToken.PackagePublicPath)
                                        .borrow<&SimpleToken.Package{SimpleToken.PackagePublic}>()
                                        ?? panic("Could not borrow the public SimpleToken.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenant: self.Tenant).createNewMinter()
        )
        log("Gave a SimpleToken.NFTMinter to the recipient's account.")
    }
}

