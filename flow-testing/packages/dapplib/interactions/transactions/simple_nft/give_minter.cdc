import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address) {

    let Tenant: Address
    let AdminsSNFTPackage: &SimpleNFT.Bundle
    let RecipientsSNFTPackage: &SimpleNFT.Bundle{SimpleNFT.PublicBundle}
    
    prepare(tenantOwner: AuthAccount) {
        self.Tenant = tenantOwner.address
        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleNFT.Bundle>(from: SimpleNFT.BundleStoragePath)
                                    ?? panic("Could not borrow the SimpleNFT.Bundle from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleNFT.BundlePublicPath)
                                        .borrow<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>()
                                        ?? panic("Could not borrow the public SimpleNFT.Bundle from the recipient.")
    }

    execute {
        
        self.RecipientsSNFTPackage.depositMinter(NFTMinter: <- self.AdminsSNFTPackage.borrowAdmin(tenant: self.Tenant).createNFTMinter())
        log("Gave a SimpleNFT.NFTMinter to the recipient's account.")
    }
}