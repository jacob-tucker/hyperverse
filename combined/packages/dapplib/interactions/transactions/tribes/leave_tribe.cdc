import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(tenantOwner: Address) {

    let TenantID: String
    let TribesIdentity: &Tribes.Identity

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(Tribes.getType().identifier)

        let SignerTribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesIdentity = SignerTribesPackage.borrowIdentity(tenantID: self.TenantID)
    }

    execute {
        Tribes.leaveTribe(identity: self.TribesIdentity)
        log("This signer left their Tribe.")
    }
}

