import Rewards from "../../../contracts/Project/Rewards.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(tenant: Address) {
    let RewardsTenant: &Rewards.Tenant{Rewards.IState}
    let Collection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
    prepare(signer: AuthAccount) {
        self.RewardsTenant = getAccount(tenant).getCapability(Rewards.getMetadata().tenantPublicPath)
                                .borrow<&Rewards.Tenant{Rewards.IState}>()!
        self.Collection = getAccount(signer.address).getCapability(SimpleNFT.CollectionPublicPath)
                            .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()!
    }

    execute {
        self.RewardsTenant.giveReward(nftCollection: self.Collection)
        log("Gave the signer the reward.")
    }
}