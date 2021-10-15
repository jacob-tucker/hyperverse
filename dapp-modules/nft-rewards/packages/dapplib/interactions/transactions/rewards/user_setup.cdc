import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"

transaction(tenant: Address) {

    let TenantState: &Rewards.Tenant{Rewards.IState}
    let Package: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        self.TenantState = getAccount(tenant).getCapability(Rewards.getMetadata().tenantPublicPath)
                        .borrow<&Rewards.Tenant{Rewards.IState}>()
                        ?? panic("Could not borrow the tenant.")

        self.Package = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.depositCollection(Collection: <- self.TenantState.simpleNFTRef().createCollection())
        log("Signer deposited a SimpleNFT Collection to their Package.")
    }
}

