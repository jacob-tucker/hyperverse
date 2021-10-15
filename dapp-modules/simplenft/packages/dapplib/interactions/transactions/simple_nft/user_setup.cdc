import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenant: Address) {

    let TenantState: &SimpleNFT.Tenant{SimpleNFT.IState}
    let Package: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        self.TenantState = getAccount(tenant).getCapability(SimpleNFT.getMetadata().tenantPublicPath)
                        .borrow<&SimpleNFT.Tenant{SimpleNFT.IState}>()
                        ?? panic("Could not borrow the tenant.")

        self.Package = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.depositCollection(Collection: <- self.TenantState.createCollection())
        log("Signer deposited a SimpleNFT Collection to their Package.")
    }
}

