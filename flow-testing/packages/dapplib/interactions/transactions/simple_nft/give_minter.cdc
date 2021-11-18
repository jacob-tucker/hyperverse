import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(recipient: Address) {

    let Tenant: Address
    let AdminsSNFTPackage: &SimpleNFT.Package
    let RecipientsSNFTPackage: &SimpleNFT.Package{SimpleNFT.PackagePublic}
    
    prepare(tenantOwner: AuthAccount) {
        self.Tenant = tenantOwner.address
        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleNFT.Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                        .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                        ?? panic("Could not borrow the public SimpleNFT.Package from the recipient.")
    }

    execute {
        
        self.RecipientsSNFTPackage.depositMinter(NFTMinter: <- self.AdminsSNFTPackage.borrowAdmin(tenant: self.Tenant).createNFTMinter())
        log("Gave a SimpleNFT.NFTMinter to the recipient's account.")
    }
}