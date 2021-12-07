import Tribes from "../../../contracts/Project/Tribes.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction(newTribeName: String, ipfsHash: String, description: String) {

    let TribesAdmin: &Tribes.Admin

    prepare(tenantOwner: AuthAccount) {
        let auth = tenantOwner.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!

        if tenantOwner.borrow<&Tribes.Admin>(from: Tribes.AdminStoragePath) == nil {
            tenantOwner.save(<- Tribes.createAdmin(auth: auth), to: Tribes.AdminStoragePath)
        }
        self.TribesAdmin = tenantOwner.borrow<&Tribes.Admin>(from: Tribes.AdminStoragePath)!
    }

    execute {
        self.TribesAdmin.addNewTribe(newTribeName: newTribeName, ipfsHash: ipfsHash, description: description)
        log("This admin has added a new tribe to join.")
    }
}

