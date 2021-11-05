import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, tenantOwner: Address, amount: UFix64) {

    let TenantID: String
    let SimpleTokenMinter: &SimpleToken.Minter
    let RecipientCollection: &SimpleToken.Vault{SimpleToken.VaultPublic}

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleToken.getType().identifier)

        let SignerSimpleTokenPackage = signer.borrow<&SimpleToken.Package>(from: SimpleToken.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleToken.Package.")

        self.SimpleTokenMinter = SignerSimpleTokenPackage.borrowMinter(tenantID: self.TenantID)

        let RecipientSimpleTokenPackage = getAccount(recipient).getCapability(SimpleToken.PackagePublicPath)
                                            .borrow<&SimpleToken.Package{SimpleToken.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleToken.Package.")
        self.RecipientCollection = RecipientSimpleTokenPackage.borrowVaultPublic(tenantID: self.TenantID)
    }

    execute {
        let vault <- self.SimpleTokenMinter.mintTokens(amount: amount) 
        self.RecipientCollection.deposit(vault: <-vault)
        log("Minted a SimpleToken into the recipient's SimpleToken Collection.")
    }
}

