import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(newTribeName: String, tenantID: String) {

    let TribesAdmin: &Tribes.Admin

    prepare(tenantOwner: AuthAccount) {

        let SignerTribesPackage = tenantOwner.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesAdmin = SignerTribesPackage.borrowAdmin(tenantID: tenantID)
    }

    execute {
        self.TribesAdmin.addNewTribe(newTribeName: newTribeName)
        log("This admin has added a new tribe to join.")
    }
}

