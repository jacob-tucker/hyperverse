import Rewards from "../../../contracts/Project/Rewards.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        // Save the Rewards Tenant to account storage.
        signer.save(<- Rewards.instance(), to: Rewards.getMetadata().tenantStoragePath)
        let metadata = Rewards.getMetadata()
        signer.link<&Rewards.Tenant{Rewards.IState, IHyperverseComposable.ITenantID}>(metadata.tenantPublicPath, target: metadata.tenantStoragePath)
    }

    execute {
        log("Saved the new Rewards Tenant to the signer's account storage.")
    }
}