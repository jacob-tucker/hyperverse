import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, amount: UFix64, tenantOwner: Address) {

    let SignerVault: &SimpleToken.Vault
    let RecipientVault: &SimpleToken.Vault{SimpleToken.VaultPublic}

    prepare(signer: AuthAccount) {                  
        let SignerBundle = signer.borrow<&SimpleToken.Bundle>(from: SimpleToken.BundleStoragePath)
                                ?? panic("Could not borrow the signer's SimpleToken Bundle.")

        self.SignerVault = SignerBundle.borrowVault(tenant: tenantOwner)

        let RecipientSimpleTokenBundle = getAccount(recipient).getCapability(SimpleToken.BundlePublicPath)
                                            .borrow<&SimpleToken.Bundle{SimpleToken.PublicBundle}>()
                                            ?? panic("Could not borrow the recipient's SimpleToken.Bundle.")
        self.RecipientVault = RecipientSimpleTokenBundle.borrowVaultPublic(tenant: tenantOwner)
    }

    execute {
        self.RecipientVault.deposit(from: <- self.SignerVault.withdraw(amount: amount))
        log("Transferred SimpleToken from the signer into the recipient's SimpleToken Collection.")
    }
}

