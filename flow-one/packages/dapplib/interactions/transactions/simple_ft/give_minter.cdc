import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction() {

    let Tenant: Address
    
    prepare(tenantOwner: AuthAccount, recipient: AuthAccount) {
        self.Tenant = tenantOwner.address

        let auth = tenantOwner.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!

        if recipient.borrow<&SimpleToken.Minter>(from: SimpleToken.MinterStoragePath) == nil {
            recipient.save(<- SimpleToken.createMinter(), to: SimpleToken.MinterStoragePath)
        }
        let minter = recipient.borrow<&SimpleToken.Minter>(from: SimpleToken.MinterStoragePath)!
        
        if tenantOwner.borrow<&SimpleToken.Admin>(from: SimpleToken.AdminStoragePath) == nil {
            tenantOwner.save(<- SimpleToken.createAdmin(auth: auth), to: SimpleToken.AdminStoragePath)
        }
        let admin = tenantOwner.borrow<&SimpleToken.Admin>(from: SimpleToken.AdminStoragePath)!

        admin.permissionMinter(minter: minter)
    }

    execute {
        log("Gave a SimpleToken.Minter to the recipient's account.")
    }
}

