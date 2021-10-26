import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(recipient: Address, tenantID: String, amount: UFix64) {

    let SimpleFTMinter: &SimpleFT.Minter
    let RecipientCollection: &SimpleFT.Vault{SimpleFT.VaultPublic}

    prepare(signer: AuthAccount) {

        let SignerSimpleFTPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleFT.Package.")

        self.SimpleFTMinter = SignerSimpleFTPackage.borrowMinter(tenantID: tenantID)

        let RecipientSimpleFTPackage = getAccount(recipient).getCapability(SimpleFT.PackagePublicPath)
                                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleFT.Package.")
        self.RecipientCollection = RecipientSimpleFTPackage.borrowVaultPublic(tenantID: tenantID)
    }

    execute {
        let vault <- self.SimpleFTMinter.mintTokens(amount: amount) 
        self.RecipientCollection.deposit(vault: <-vault)
        log("Minted a SimpleFT into the recipient's SimpleFT Collection.")
    }
}

