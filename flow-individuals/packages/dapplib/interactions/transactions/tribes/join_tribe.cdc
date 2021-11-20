import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(tenantOwner: Address, tribeName: String) {

    let TribesIdentity: &Tribes.Identity

    prepare(signer: AuthAccount) {
        let SignerTribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesIdentity = SignerTribesPackage.borrowIdentity(tenant: tenantOwner)
    }

    execute {
        Tribes.joinTribe(identity: self.TribesIdentity, tribe: tribeName)
        log("This signer joined a Tribe.")
    }
}

 