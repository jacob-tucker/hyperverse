import Rewards from "../../../contracts/Project/Rewards.cdc"

transaction(recipient: Address) {
    let RewardsTenant: &Rewards.Tenant
    let RecipientPackage: &Rewards.Package{Rewards.PackagePublic}

    prepare(signer: AuthAccount) {
        self.RewardsTenant = signer.borrow<&Rewards.Tenant>(from: Rewards.getMetadata().tenantStoragePath)
                                ?? panic("Could not borrow the tenant storage path.")

        self.RecipientPackage = getAccount(recipient).getCapability(Rewards.PackagePublicPath)
                                    .borrow<&Rewards.Package{Rewards.PackagePublic}>()
                                    ?? panic("Could not borrow the public Package from the recipient.")
    }

    execute {
        self.RewardsTenant.mintNFT(package: self.RecipientPackage)
    
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

