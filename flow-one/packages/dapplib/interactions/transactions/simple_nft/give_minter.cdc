import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction() {

    let Tenant: Address
    
    prepare(tenantOwner: AuthAccount, recipient: AuthAccount) {
        self.Tenant = tenantOwner.address
        
        let auth = tenantOwner.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!

        if recipient.borrow<&SimpleNFT.Minter>(from: SimpleNFT.MinterStoragePath) == nil {
            recipient.save(<- SimpleNFT.createMinter(), to: SimpleNFT.MinterStoragePath)
        }
        let minter = recipient.borrow<&SimpleNFT.Minter>(from: SimpleNFT.MinterStoragePath)!
        
        if tenantOwner.borrow<&SimpleNFT.Admin>(from: SimpleNFT.AdminStoragePath) == nil {
            tenantOwner.save(<- SimpleNFT.createAdmin(auth: auth), to: SimpleNFT.AdminStoragePath)
        }
        let admin = tenantOwner.borrow<&SimpleNFT.Admin>(from: SimpleNFT.AdminStoragePath)!

        admin.permissionMinter(minter: minter)

    }

    execute {
        log("Gave a SimpleNFT.Minter to the recipient's account.")
    }
}