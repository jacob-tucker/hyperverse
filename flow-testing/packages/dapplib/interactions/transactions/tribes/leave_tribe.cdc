import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(tenantOwner: Address) {

    let TribesIdentity: &Tribes.Identity

    prepare(signer: AuthAccount) {

        let SignerTribesPackage = signer.borrow<&Tribes.Bundle>(from: Tribes.BundleStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Bundle.")

        self.TribesIdentity = SignerTribesPackage.borrowIdentity(tenant: tenantOwner)
    }

    execute {
        self.TribesIdentity.leaveTribe()
        log("This signer left their Tribe.")
    }
}

