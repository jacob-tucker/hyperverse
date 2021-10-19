import Rewards from "../../../contracts/Project/Rewards.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction(tenant: Address) {
    let RewardsTenant: &Rewards.Tenant{Rewards.IState}
    let SignerPackage: &Rewards.Package{Rewards.PackagePublic}
    prepare(signer: AuthAccount) {
        self.RewardsTenant = getAccount(tenant).getCapability(Rewards.getMetadata().tenantPublicPath)
                                .borrow<&Rewards.Tenant{Rewards.IState}>()!

        self.SignerPackage = signer.getCapability(Rewards.PackagePublicPath)
                                .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                ?? panic("Could not borrow the public Package from the signer.")
    }

    execute {
        self.RewardsTenant.giveReward(package: self.SignerPackage)
        log("Gave the signer the reward.")
    }
}