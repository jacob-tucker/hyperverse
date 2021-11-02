import Rewards from "../../../contracts/Project/Rewards.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// The signer is the recipient
transaction(tenantOwner: Address) {

    let TenantID: String
    let TenantsRewardsPackage: &Rewards.Package{Rewards.PackagePublic}
    let RecipientsRewardsPackage: &Rewards.Package{Rewards.PackagePublic}

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(Rewards.getType().identifier)

        self.TenantsRewardsPackage = getAccount(tenantOwner).getCapability(Rewards.PackagePublicPath)
                                .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                ?? panic("Could not borrow the public SimpleNFT.Package")

        self.RecipientsRewardsPackage = signer.getCapability(Rewards.PackagePublicPath)
                                            .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                            ?? panic("Could not borrow the public Package from the signer.")
    }

    execute {
        Rewards.giveReward(tenantID: self.TenantID, minterPackage: self.TenantsRewardsPackage, recipientPackage: self.RecipientsRewardsPackage)
        log("Gave the signer the reward.")
    }
}