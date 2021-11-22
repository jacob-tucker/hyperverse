import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(tenantOwner: Address, tribeName: String) {

    let TribesIdentity: &Tribes.Identity

    prepare(signer: AuthAccount) {
        let SignerTribesPackage = signer.borrow<&Tribes.Bundle>(from: Tribes.BundleStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Bundle.")

        self.TribesIdentity = SignerTribesPackage.borrowIdentity(tenant: tenantOwner)
    }

    execute {
        Tribes.joinTribe(identity: self.TribesIdentity, tribe: tribeName)
        log("This signer joined a Tribe.")
    }
}

 