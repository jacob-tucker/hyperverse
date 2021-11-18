import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, tenantOwner: Address, amount: UFix64) {

    let SimpleTokenMinter: &SimpleToken.Minter
    let RecipientCollection: &SimpleToken.Vault{SimpleToken.VaultPublic}

    prepare(signer: AuthAccount) {
        let SignerSimpleTokenPackage = signer.borrow<&SimpleToken.Package>(from: SimpleToken.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleToken.Package.")

        self.SimpleTokenMinter = SignerSimpleTokenPackage.borrowMinter(tenant: tenantOwner)

        let RecipientSimpleTokenPackage = getAccount(recipient).getCapability(SimpleToken.PackagePublicPath)
                                            .borrow<&SimpleToken.Package{SimpleToken.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleToken.Package.")
        self.RecipientCollection = RecipientSimpleTokenPackage.borrowVaultPublic(tenant: tenantOwner)
    }

    execute {
        let vault <- self.SimpleTokenMinter.mintTokens(amount: amount) 
        self.RecipientCollection.deposit(from: <-vault)
        log("Minted a SimpleToken into the recipient's SimpleToken Collection.")
    }
}

