import MorganNFT from "../../../contracts/Project/MorganNFT.cdc"
import NonFungibleToken from "../../../contracts/Flow/NonFungibleToken.cdc"

transaction(tenantID: UInt64) {

    prepare(signer: AuthAccount) {
        signer.save(<- MorganNFT.createEmptyCollectionSpecifyTenant(tenantID: tenantID), to: MorganNFT.CollectionStoragePath)
        
        signer.link<&MorganNFT.Collection{NonFungibleToken.CollectionPublic}>(MorganNFT.CollectionPublicPath, target: MorganNFT.CollectionStoragePath)
    }

    execute {
        log("Signer has a MorganNFT Collection.")
    }
}

