import Tribes from "../../../contracts/Project/Tribes.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address) {

    let TenantID: String
    let Package: &Tribes.Package

    prepare(signer: AuthAccount) {
        let TenantPackage = getAccount(tenantOwner).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

        self.Package = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: self.TenantID)
        log("Signer setup their Package for Tribes and its dependencies.")
    }
}

