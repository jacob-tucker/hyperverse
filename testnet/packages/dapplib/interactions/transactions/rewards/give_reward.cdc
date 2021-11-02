import Rewards from 0x26a365de6d6237cd
import SimpleNFT from 0x26a365de6d6237cd

// The signer is the recipient
transaction(tenantOwner: Address, tenantID: String) {

    let TenantsRewardsPackage: &Rewards.Package{Rewards.PackagePublic}
    let RecipientsRewardsPackage: &Rewards.Package{Rewards.PackagePublic}

    prepare(signer: AuthAccount) {

        self.TenantsRewardsPackage = getAccount(tenantOwner).getCapability(Rewards.PackagePublicPath)
                                .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")

        self.RecipientsRewardsPackage = signer.getCapability(Rewards.PackagePublicPath)
                                            .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                            ?? panic("Could not borrow the public Package from the signer.")
    }

    execute {
        Rewards.giveReward(tenantID: tenantID, minterPackage: self.TenantsRewardsPackage, recipientPackage: self.RecipientsRewardsPackage)
        log("Gave the signer the reward.")
    }
}