import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import HyperverseService from "../../../contracts/Hyperverse/HyperverseService.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        // Get the AuthNFT capability from private account storage.
        let authNFT = signer.getCapability<&HyperverseService.AuthNFT>(HyperverseService.AuthPrivatePath)
        // Get the TenantCollection reference from account storage.
        let tenantCollection = signer.borrow<&HyperverseService.TenantCollection{HyperverseService.TenantCollectionPublic}>(from: HyperverseService.TenantCollectionStoragePath)
                            ?? panic("Could not borrow the TenantCollection reference from signer's account storage.")

        // Save the NFT Marketplace Tenant to account storage.
        NFTMarketplace.instance(authNFT: authNFT, tenantCollection: tenantCollection)
    }

    execute {
        log("Saved the new NFT Marketplace Tenant to the signer's TenantCollection.")
    }
}