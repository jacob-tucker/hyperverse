import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

// Needs to be called every time a user comes into a new vault for FTs
transaction(tenant: Address) {

    let TenantState: Capability<&SimpleFT.Tenant{SimpleFT.IState}>
    let Package: &SimpleFT.Package

    prepare(signer: AuthAccount) {
        self.TenantState = getAccount(tenant).getCapability<&SimpleFT.Tenant{SimpleFT.IState}>(SimpleFT.getMetadata().tenantPublicPath)

        self.Package = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.depositVault(Vault: <- self.TenantState.borrow()!.createVault(tenantCapability: self.TenantState))
        log("Signer deposited a SimpleFT Vault to their Package.")
    }
}

