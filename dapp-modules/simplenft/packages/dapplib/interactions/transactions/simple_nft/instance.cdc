import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        // Save the SimpleNFT Tenant to account storage.
        signer.save(<- SimpleNFT.instance(), to: SimpleNFT.getMetadata().tenantStoragePath)
        let metadata = SimpleNFT.getMetadata()
        signer.link<&SimpleNFT.Tenant{SimpleNFT.IState, IHyperverseComposable.ITenantID}>(metadata.tenantPublicPath, target: metadata.tenantStoragePath)
    }

    execute {
        log("Saved the new SimpleNFT Tenant to the signer's account storage.")
    }
}