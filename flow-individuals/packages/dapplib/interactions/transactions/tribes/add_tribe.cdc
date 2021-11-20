import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(newTribeName: String, ipfsHash: String, description: String) {

    let TribesAdmin: &Tribes.Admin

    prepare(tenantOwner: AuthAccount) {
        let SignerTribesPackage = tenantOwner.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesAdmin = SignerTribesPackage.borrowAdmin(tenant: tenantOwner.address)
    }

    execute {
        self.TribesAdmin.addNewTribe(newTribeName: newTribeName, ipfsHash: ipfsHash, description: description)
        log("This admin has added a new tribe to join.")
    }
}

