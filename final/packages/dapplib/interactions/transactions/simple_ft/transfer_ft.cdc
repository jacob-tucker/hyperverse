import SimpleFT from 0x26a365de6d6237cd

transaction(recipient: Address, amount: UFix64, tenantID: String) {

    let SignerVault: &SimpleFT.Vault
    let RecipientVault: &SimpleFT.Vault{SimpleFT.VaultPublic}

    prepare(signer: AuthAccount) {

        let SignerPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                ?? panic("Could not borrow the signer's SimpleFT Package.")

        self.SignerVault = SignerPackage.borrowVault(tenantID: tenantID)

        let RecipientSimpleFTPackage = getAccount(recipient).getCapability(/public/SimpleFTPackage)
                                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleFT.Package.")
        self.RecipientVault = RecipientSimpleFTPackage.borrowVaultPublic(tenantID: tenantID)
    }

    execute {
        self.RecipientVault.deposit(vault: <- self.SignerVault.withdraw(amount: amount))
        log("Transferred SimpleFT from the signer into the recipient's SimpleFT Collection.")
    }
}

