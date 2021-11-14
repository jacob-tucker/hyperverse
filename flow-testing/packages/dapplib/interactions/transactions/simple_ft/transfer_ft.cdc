import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, amount: UFix64, tenantOwner: Address) {

    let TenantID: String
    let SignerVault: &SimpleToken.Vault
    let RecipientVault: &SimpleToken.Vault{SimpleToken.VaultPublic}

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleToken.getType().identifier)
                        
        let SignerPackage = signer.borrow<&SimpleToken.Package>(from: SimpleToken.PackageStoragePath)
                                ?? panic("Could not borrow the signer's SimpleToken Package.")

        self.SignerVault = SignerPackage.borrowVault(tenantID: self.TenantID)

        let RecipientSimpleTokenPackage = getAccount(recipient).getCapability(/public/SimpleTokenPackage)
                                            .borrow<&SimpleToken.Package{SimpleToken.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleToken.Package.")
        self.RecipientVault = RecipientSimpleTokenPackage.borrowVaultPublic(tenantID: self.TenantID)
    }

    execute {
        self.RecipientVault.deposit(vault: <- self.SignerVault.withdraw(amount: amount))
        log("Transferred SimpleToken from the signer into the recipient's SimpleToken Collection.")
    }
}

