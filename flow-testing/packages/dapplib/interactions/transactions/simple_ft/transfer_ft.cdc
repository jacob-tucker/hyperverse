import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, amount: UFix64, tenantOwner: Address) {

    let SignerVault: &SimpleToken.Vault
    let RecipientVault: &SimpleToken.Vault{SimpleToken.VaultPublic}

    prepare(signer: AuthAccount) {                  
        let SignerPackage = signer.borrow<&SimpleToken.Package>(from: SimpleToken.PackageStoragePath)
                                ?? panic("Could not borrow the signer's SimpleToken Package.")

        self.SignerVault = SignerPackage.borrowVault(tenant: tenantOwner)

        let RecipientSimpleTokenPackage = getAccount(recipient).getCapability(/public/SimpleTokenPackage)
                                            .borrow<&SimpleToken.Package{SimpleToken.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleToken.Package.")
        self.RecipientVault = RecipientSimpleTokenPackage.borrowVaultPublic(tenant: tenantOwner)
    }

    execute {
        self.RecipientVault.deposit(from: <- self.SignerVault.withdraw(amount: amount))
        log("Transferred SimpleToken from the signer into the recipient's SimpleToken Collection.")
    }
}

