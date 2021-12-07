import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, tenantOwner: Address, amount: UFix64) {

    let SimpleTokenMinter: &SimpleToken.Minter
    let RecipientVault: &SimpleToken.Vault{SimpleToken.VaultPublic}

    prepare(signer: AuthAccount) {
        self.SimpleTokenMinter = signer.borrow<&SimpleToken.Minter>(from: SimpleToken.MinterStoragePath)
                                    ?? panic("Could not borrow the SimpleToken.Minter")

        self.RecipientVault = getAccount(recipient).getCapability(SimpleToken.VaultPublicPath)
                                            .borrow<&SimpleToken.Vault{SimpleToken.VaultPublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleToken.Vault")
    }

    execute {
        let vault <- self.SimpleTokenMinter.mintTokens(tenantOwner, amount: amount) 
        self.RecipientVault.deposit(from: <-vault)
        log("Minted SimpleToken into the recipient's SimpleToken.Vault.")
    }
}

