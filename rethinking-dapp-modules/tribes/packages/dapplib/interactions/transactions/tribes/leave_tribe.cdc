import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(tenantID: UInt64) {
    let TribesIdentity: &Tribes.Identity

    prepare(signer: AuthAccount) {

        let SignerTribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesIdentity = SignerTribesPackage.borrowIdentity(tenantID: tenantID)
    }

    execute {
        Tribes.leaveTribe(identity: self.TribesIdentity)
        log("This signer left their Tribe.")
    }
}

