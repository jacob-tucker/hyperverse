import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(tenantID: UInt64) {
    let AdminsSNFTPackage: &SimpleNFT.Package
    let RecipientsSNFTPackage: &SimpleNFT.Package
    
    prepare(signer: AuthAccount, recipient: AuthAccount) {
        self.AdminsSNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleNFT.Package from the signer.")

        self.RecipientsSNFTPackage = recipient.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleNFT.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(NFTMinter: <- self.AdminsSNFTPackage.borrowAdmin(tenantID: tenantID).createNFTMinter())
        log("Gave a SimpleNFT.NFTMinter to the recipient's account.")
    }
}

