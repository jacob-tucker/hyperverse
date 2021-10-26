import Rewards from "../../../contracts/Project/Rewards.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address) {

    let TenantID: String
    let Package: &Rewards.Package

    prepare(signer: AuthAccount) {

        let TenantPackage = getAccount(tenantOwner).getCapability(Rewards.PackagePublicPath)
                                .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

        self.Package = signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: self.TenantID)
        log("Signer setup their Rewards.Package for itself and its dependencies.")
    }
}

