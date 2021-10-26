import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantOwner: Address) {

    let TenantID: String
    let Package: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        let TenantPackage = getAccount(tenantOwner).getCapability(SimpleNFT.PackagePublicPath)
                                .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")
        self.TenantID = tenantOwner.toString().concat(".").concat(TenantPackage.uuid.toString())

        self.Package = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: self.TenantID)
        log("Signer setup their Package for SimpleNFT and its dependencies.")
    }
}

