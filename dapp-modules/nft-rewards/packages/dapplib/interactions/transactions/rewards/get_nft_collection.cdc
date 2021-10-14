import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import NonFungibleToken from "../../../contracts/Flow/NonFungibleToken.cdc"

transaction(tenantID: UInt64) {

    prepare(signer: AuthAccount) {
        signer.save(<- SimpleNFT.createEmptyCollection(tenantID: tenantID), to: SimpleNFT.CollectionStoragePath)
        
        signer.link<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>(SimpleNFT.CollectionPublicPath, target: SimpleNFT.CollectionStoragePath)
    }

    execute {
        log("Signer has a SimpleNFT Collection.")
    }
}

