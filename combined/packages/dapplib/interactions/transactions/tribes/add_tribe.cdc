import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(tenantID: UInt64, newTribeName: String) {
    let TribesAdmin: &Tribes.Admin

    prepare(signer: AuthAccount) {

        let SignerTribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesAdmin = SignerTribesPackage.borrowAdmin(tenantID: tenantID)
    }

    execute {
        self.TribesAdmin.addNewTribe(newTribeName: newTribeName)
        log("This admin has added a new tribe to join.")
    }
}

