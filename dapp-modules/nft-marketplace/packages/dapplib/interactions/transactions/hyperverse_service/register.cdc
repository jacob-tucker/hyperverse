import FlowToken from "../../../contracts/Flow/FlowToken.cdc"
import HyperverseService from "../../../contracts/Hyperverse/HyperverseService.cdc"

transaction() {

    prepare(signer: AuthAccount) {
        signer.link<&FlowToken.Vault>(/private/flowTokenVault, target: /storage/flowTokenVault)
        let flowTokenVault = signer.getCapability<&FlowToken.Vault>(/private/flowTokenVault)
            
        // Save an AuthNFT to account storage.
        signer.save(<- HyperverseService.register(flowTokenVault: flowTokenVault), to: HyperverseService.AuthStoragePath)
        // We link our new AuthNFT to a private path so we can borrow it as a capability in the future.
        signer.link<&HyperverseService.AuthNFT>(HyperverseService.AuthPrivatePath, target: HyperverseService.AuthStoragePath)

        // Save a TenantCollection to account storage.
        signer.save(<- HyperverseService.createEmptyTenantCollection(), to: HyperverseService.TenantCollectionStoragePath)
        // Link the TenantCollection to a public path using a public capability.
        signer.link<&HyperverseService.TenantCollection{HyperverseService.TenantCollectionPublic}>(HyperverseService.TenantCollectionPublicPath, target: HyperverseService.TenantCollectionStoragePath)
    }

    execute {
        log("Signer registered with Hyperverse and received an AuthNFT and TenantCollection.")
    }
}

