import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"

transaction(recipient: Address) {
    let RewardsTenant: &Rewards.Tenant
    let RecipientCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.RewardsTenant = signer.borrow<&Rewards.Tenant>(from: Rewards.getMetadata().tenantStoragePath)
                                ?? panic("Could not borrow the tenant storage path.")

        let RecipientSimpleNFTPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                            .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleNFT.Package.")
        self.RecipientCollection = RecipientSimpleNFTPackage.borrowCollectionPublic(tenantID: self.RewardsTenant.simpleNFTRef().id)
    }

    execute {
        self.RewardsTenant.mintNFT(collection: self.RecipientCollection)
    
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

