import Rewards from "../../../contracts/Project/Rewards.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// The signer is the recipient
transaction(tenantOwner: Address) {

    let TenantsRewardsPackage: &Rewards.Bundle{Rewards.PublicBundle}
    let RecipientsRewardsPackage: &Rewards.Bundle{Rewards.PublicBundle}

    prepare(signer: AuthAccount) {

        self.TenantsRewardsPackage = getAccount(tenantOwner).getCapability(Rewards.BundlePublicPath)
                                .borrow<&Rewards.Bundle{Rewards.PublicBundle}>()
                                ?? panic("Could not borrow the public SimpleNFT.Bundle")

        self.RecipientsRewardsPackage = signer.getCapability(Rewards.BundlePublicPath)
                                            .borrow<&Rewards.Bundle{Rewards.PublicBundle}>()
                                            ?? panic("Could not borrow the public Bundle from the signer.")
    }

    execute {
        Rewards.giveReward(tenant: tenantOwner, minterBundle: self.TenantsRewardsPackage, recipientBundle: self.RecipientsRewardsPackage)
        log("Gave the signer the reward.")
    }
}