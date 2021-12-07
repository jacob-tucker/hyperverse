import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

transaction(recipient: Address, amount: UFix64, tenantOwner: Address) {
    prepare(signer: AuthAccount) {
        let signerVault = signer.borrow<&SimpleToken.Vault>(from: SimpleToken.VaultStoragePath)
                                    ?? panic("Could not borrow the signer's SimpleToken.Collection.")

        let recipientVault = getAccount(recipient).getCapability(SimpleToken.VaultPublicPath)
                                    .borrow<&SimpleToken.Vault{SimpleToken.VaultPublic}>()
                                    ?? panic("Could not borrow the recipient's SimpleToken.Collection")

        recipientVault.deposit(from: <- signerVault.withdraw(tenantOwner, amount: amount))
    }

    execute {
        log("Transfered the Tokens from the signer to the recipient.")
    }
}