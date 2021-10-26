import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction() {

    let TenantID: String
    let AdminsSNFTPackage: &SimpleNFT.Package
    let RecipientsSNFTPackage: &SimpleNFT.Package
    
    prepare(tenantOwner: AuthAccount, recipient: AuthAccount) {
        let TenantPackage = getAccount(tenantOwner.address).getCapability(SimpleNFT.PackagePublicPath)
                                .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.address.toString().concat(".").concat(TenantPackage.uuid.toString())

        self.AdminsSNFTPackage = tenantOwner.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleNFT.Package from the signer.")

        self.RecipientsSNFTPackage = recipient.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleNFT.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(NFTMinter: <- self.AdminsSNFTPackage.borrowAdmin(tenantID: self.TenantID).createNFTMinter())
        log("Gave a SimpleNFT.NFTMinter to the recipient's account.")
    }
}

