import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address) {

    let TenantID: String
    let Package: &SimpleFT.Package

    prepare(signer: AuthAccount) {
        let TenantPackage = getAccount(tenantOwner).getCapability(SimpleFT.PackagePublicPath)
                                .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

        self.Package = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: self.TenantID)
        log("Signer setup their Package for SimpleFT and its dependencies.")
    }
}

