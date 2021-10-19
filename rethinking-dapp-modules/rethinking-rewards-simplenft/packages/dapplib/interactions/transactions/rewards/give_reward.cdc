import Rewards from "../../../contracts/Project/Rewards.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// The signer is the recipient
transaction(tenantID: UInt64, minter: Address) {
    let MintersRewardsPackage: &Rewards.Package{Rewards.PackagePublic}
    let RecipientsRewardsPackage: &Rewards.Package{Rewards.PackagePublic}
    prepare(signer: AuthAccount) {
        self.RecipientsRewardsPackage = signer.getCapability(Rewards.PackagePublicPath)
                                            .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                            ?? panic("Could not borrow the public Package from the signer.")

        self.MintersRewardsPackage = getAccount(minter).getCapability(Rewards.PackagePublicPath)
                                        .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                        ?? panic("Could not borrow the public Package from the minter.")
    }

    execute {
        Rewards.giveReward(tenantID: tenantID, minterPackage: self.MintersRewardsPackage, recipientPackage: self.RecipientsRewardsPackage)
        log("Gave the signer the reward.")
    }
}