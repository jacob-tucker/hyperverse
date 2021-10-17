import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        // Save the SimpleFT Tenant to account storage.
        signer.save(<- SimpleFT.instance(), to: SimpleFT.getMetadata().tenantStoragePath)
        let metadata = SimpleFT.getMetadata()
        signer.link<&SimpleFT.Tenant{SimpleFT.IState, IHyperverseComposable.ITenantID}>(metadata.tenantPublicPath, target: metadata.tenantStoragePath)
    }

    execute {
        log("Saved the new SimpleFT Tenant to the signer's account storage.")
    }
}