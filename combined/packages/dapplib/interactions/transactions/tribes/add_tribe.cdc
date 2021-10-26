import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(newTribeName: String) {

    let TenantID: String
    let TribesAdmin: &Tribes.Admin

    prepare(tenantOwner: AuthAccount) {

        let TenantPackage = getAccount(tenantOwner.address).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.address.toString().concat(".").concat(TenantPackage.uuid.toString())

        let SignerTribesPackage = tenantOwner.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesAdmin = SignerTribesPackage.borrowAdmin(tenantID: self.TenantID)
    }

    execute {
        self.TribesAdmin.addNewTribe(newTribeName: newTribeName)
        log("This admin has added a new tribe to join.")
    }
}

