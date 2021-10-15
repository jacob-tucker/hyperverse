import Rewards from "../../../contracts/Project/Rewards.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(tenant: Address) {
    let RewardsTenant: &Rewards.Tenant{Rewards.IState}
    let SimpleNFTCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    prepare(signer: AuthAccount) {
        self.RewardsTenant = getAccount(tenant).getCapability(Rewards.getMetadata().tenantPublicPath)
                                .borrow<&Rewards.Tenant{Rewards.IState}>()!

        let SimpleNFTPackage = getAccount(signer.address).getCapability(SimpleNFT.PackagePublicPath)
                                    .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                    ?? panic("Could not borrow the signer's SimpleNFT Package.")

        self.SimpleNFTCollection = SimpleNFTPackage.borrowCollectionPublic(tenantID: self.RewardsTenant.simpleNFTRef().id)
    }

    execute {
        self.RewardsTenant.giveReward(nftCollection: self.SimpleNFTCollection)
        log("Gave the signer the reward.")
    }
}