import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(recipient: Address, amount: UFix64, tenantOwner: Address) {

    let TenantID: String
    let SignerVault: &SimpleFT.Vault
    let RecipientVault: &SimpleFT.Vault{SimpleFT.VaultPublic}

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleFT.getType().identifier)
                        
        let SignerPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                ?? panic("Could not borrow the signer's SimpleFT Package.")

        self.SignerVault = SignerPackage.borrowVault(tenantID: self.TenantID)

        let RecipientSimpleFTPackage = getAccount(recipient).getCapability(/public/SimpleFTPackage)
                                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleFT.Package.")
        self.RecipientVault = RecipientSimpleFTPackage.borrowVaultPublic(tenantID: self.TenantID)
    }

    execute {
        self.RecipientVault.deposit(vault: <- self.SignerVault.withdraw(amount: amount))
        log("Transferred SimpleFT from the signer into the recipient's SimpleFT Collection.")
    }
}

