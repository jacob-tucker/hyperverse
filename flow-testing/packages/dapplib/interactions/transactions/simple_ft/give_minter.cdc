import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address) {

    let Tenant: Address
    let AdminsSNFTPackage: &SimpleToken.Bundle
    let RecipientsSNFTPackage: &SimpleToken.Bundle{SimpleToken.PublicBundle}
    
    prepare(tenantOwner: AuthAccount) {
        self.Tenant = tenantOwner.address
        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleToken.Bundle>(from: SimpleToken.BundleStoragePath)
                                    ?? panic("Could not borrow the SimpleToken.Bundle from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleToken.BundlePublicPath)
                                        .borrow<&SimpleToken.Bundle{SimpleToken.PublicBundle}>()
                                        ?? panic("Could not borrow the public SimpleToken.Bundle from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(
            Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenant: self.Tenant).createNewMinter()
        )
        log("Gave a SimpleToken.NFTMinter to the recipient's account.")
    }
}

