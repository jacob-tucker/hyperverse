import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(recipient: Address, tenantOwner: Address, amount: UFix64) {

    let TenantID: String
    let SimpleFTMinter: &SimpleFT.Minter
    let RecipientCollection: &SimpleFT.Vault{SimpleFT.VaultPublic}

    prepare(signer: AuthAccount) {
        self.TenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(SimpleFT.getType().identifier)
                        .concat(".0")

        let SignerSimpleFTPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                        ?? panic("Could not borrow the signer's SimpleFT.Package.")

        self.SimpleFTMinter = SignerSimpleFTPackage.borrowMinter(tenantID: self.TenantID)

        let RecipientSimpleFTPackage = getAccount(recipient).getCapability(SimpleFT.PackagePublicPath)
                                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleFT.Package.")
        self.RecipientCollection = RecipientSimpleFTPackage.borrowVaultPublic(tenantID: self.TenantID)
    }

    execute {
        let vault <- self.SimpleFTMinter.mintTokens(amount: amount) 
        self.RecipientCollection.deposit(vault: <-vault)
        log("Minted a SimpleFT into the recipient's SimpleFT Collection.")
    }
}

