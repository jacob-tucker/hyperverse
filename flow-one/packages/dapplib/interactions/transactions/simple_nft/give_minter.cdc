import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction() {

    let Tenant: Address
    
    prepare(tenantOwner: AuthAccount, recipient: AuthAccount) {
        self.Tenant = tenantOwner.address
        
        let auth = tenantOwner.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!

        if recipient.borrow<&SimpleNFT.NFTMinter>(from: /storage/SimpleNFTMinter) == nil {
            recipient.save(<- SimpleNFT.getNFTMinter(), to: /storage/SimpleNFTMinter)
        }

        let nftMinter = recipient.borrow<&SimpleNFT.NFTMinter>(from: /storage/SimpleNFTMinter)!
        
        SimpleNFT.getTenantAuth(auth: auth).permissionNFTMinter(nftMinter: nftMinter)
    }

    execute {
        log("Gave a SimpleNFT.NFTMinter to the recipient's account.")
    }
}