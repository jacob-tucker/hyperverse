import Tribes from "../../../contracts/Project/Tribes.cdc"

transaction(tenantOwner: Address, tribeName: String) {

    let TenantID: String
    let TribesIdentity: &Tribes.Identity

    prepare(signer: AuthAccount) {

        let TenantPackage = getAccount(tenantOwner).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

        let SignerTribesPackage = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's Tribes.Package.")

        self.TribesIdentity = SignerTribesPackage.borrowIdentity(tenantID: self.TenantID)
    }

    execute {
        Tribes.joinTribe(identity: self.TribesIdentity, tribe: tribeName)
        log("This signer joined a Tribe.")
    }
}

