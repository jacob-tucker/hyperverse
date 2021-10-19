import Rewards from "../../../contracts/Project/Rewards.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        // Save the Rewards Tenant to account storage.
        signer.save(<- Rewards.instance(), to: Rewards.getMetadata().tenantStoragePath)
        let metadata = Rewards.getMetadata()
        signer.link<&Rewards.Tenant{Rewards.IState, IHyperverseComposable.ITenantID, SimpleNFT.IState}>(metadata.tenantPublicPath, target: metadata.tenantStoragePath)

        let tenant = signer.borrow<&Rewards.Tenant>(from: metadata.tenantStoragePath)!
        let sC = signer.getCapability<&Rewards.Tenant{SimpleNFT.IState}>(metadata.tenantPublicPath)
        tenant.addSC(sC: sC)
    }

    execute {
        log("Saved the new Rewards Tenant to the signer's account storage.")
    }
}