import Rewards from "../../../contracts/Project/Rewards.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenant: Address) {

    let TenantState: &Rewards.Tenant{Rewards.IState}
    let Package: &Rewards.Package

    prepare(signer: AuthAccount) {
        self.TenantState = getAccount(tenant).getCapability(Rewards.getMetadata().tenantPublicPath)
                        .borrow<&Rewards.Tenant{Rewards.IState}>()
                        ?? panic("Could not borrow the tenant.")

        self.Package = signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: self.TenantState.id)
        log("Signer setup their Package for Rewards and its dependencies.")
    }
}

