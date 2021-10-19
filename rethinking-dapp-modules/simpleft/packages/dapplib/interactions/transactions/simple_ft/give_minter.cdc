import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(tenantID: UInt64) {
    let AdminsSNFTPackage: &SimpleFT.Package
    let RecipientsSNFTPackage: &SimpleFT.Package
    
    prepare(signer: AuthAccount, recipient: AuthAccount) {
        self.AdminsSNFTPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")

        self.RecipientsSNFTPackage = recipient.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the SimpleFT.Package from the signer.")
    }

    execute {
        self.RecipientsSNFTPackage.depositMinter(Minter: <- self.AdminsSNFTPackage.borrowAdministrator(tenantID: tenantID).createNewMinter())
        log("Gave a SimpleFT.NFTMinter to the recipient's account.")
    }
}

