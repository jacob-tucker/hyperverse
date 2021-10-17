import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(recipient: Address, amount: UFix64, tenant: Address) {
    let SignerVault: &SimpleFT.Vault
    let RecipientVault: &SimpleFT.Vault{SimpleFT.VaultPublic}

    prepare(signer: AuthAccount) {
        let SimpleFTTenant = getAccount(tenant).getCapability(SimpleFT.getMetadata().tenantPublicPath)
                                    .borrow<&SimpleFT.Tenant{SimpleFT.IState}>()!

        let SignerPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                ?? panic("Could not borrow the signer's SimpleFT Package.")

        self.SignerVault = SignerPackage.borrowVault(tenantID: SimpleFTTenant.id)

        let RecipientSimpleFTPackage = getAccount(recipient).getCapability(/public/SimpleFTPackage)
                                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleFT.Package.")
        self.RecipientVault = RecipientSimpleFTPackage.borrowVaultPublic(tenantID: SimpleFTTenant.id)
    }

    execute {
        self.RecipientVault.deposit(vault: <- self.SignerVault.withdraw(amount: amount))
        log("Transferred SimpleFT from the signer into the recipient's SimpleFT Collection.")
    }
}

