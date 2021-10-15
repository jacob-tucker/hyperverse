import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction() {
    let SimpleNFTTenant: &SimpleNFT.Tenant
    let Package: &SimpleNFT.Package
    
    prepare(signer: AuthAccount, recipient: AuthAccount) {
        self.SimpleNFTTenant = signer.borrow<&SimpleNFT.Tenant>(from: SimpleNFT.getMetadata().tenantStoragePath)!
        self.Package = recipient.borrow<&SimpleNFT.Package>(from: /storage/SimpleNFTPackage)!
    }

    execute {
        self.Package.depositMinter(NFTMinter: <- self.SimpleNFTTenant.createNewMinter())
        log("Gave a SimpleNFT.NFTMinter to the recipient's account.")
    }
}

