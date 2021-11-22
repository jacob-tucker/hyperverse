import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, tenantOwner: Address, amount: UFix64) {

    let SimpleTokenMinter: &SimpleToken.Minter
    let RecipientCollection: &SimpleToken.Vault{SimpleToken.VaultPublic}

    prepare(signer: AuthAccount) {
        let SignerSimpleTokenPackage = signer.borrow<&SimpleToken.Bundle>(from: SimpleToken.BundleStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleToken.Bundle.")

        self.SimpleTokenMinter = SignerSimpleTokenPackage.borrowMinter(tenant: tenantOwner)

        let RecipientSimpleTokenPackage = getAccount(recipient).getCapability(SimpleToken.BundlePublicPath)
                                            .borrow<&SimpleToken.Bundle{SimpleToken.PublicBundle}>()
                                            ?? panic("Could not borrow the recipient's SimpleToken.Bundle.")
        self.RecipientCollection = RecipientSimpleTokenPackage.borrowVaultPublic(tenant: tenantOwner)
    }

    execute {
        let vault <- self.SimpleTokenMinter.mintTokens(amount: amount) 
        self.RecipientCollection.deposit(from: <-vault)
        log("Minted a SimpleToken into the recipient's SimpleToken Collection.")
    }
}

