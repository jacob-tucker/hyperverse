import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction(recipient: Address, tenant: Address, amount: UFix64) {
    let SimpleFTMinter: &SimpleFT.Minter
    let RecipientVault: &SimpleFT.Vault{SimpleFT.VaultPublic}

    prepare(signer: AuthAccount) {
        let SimpleFTTenant = getAccount(tenant).getCapability(SimpleFT.getMetadata().tenantPublicPath)
                                    .borrow<&SimpleFT.Tenant{SimpleFT.IState}>()!

        let SignerSimpleFTPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the signer's SimpleFT.Package.")
        self.SimpleFTMinter = SignerSimpleFTPackage.borrowMinter(tenantID: SimpleFTTenant.id)

        let RecipientSimpleFTPackage = getAccount(recipient).getCapability(/public/SimpleFTPackage)
                                            .borrow<&SimpleFT.Package{SimpleFT.PackagePublic}>()
                                            ?? panic("Could not borrow the recipient's SimpleFT.Package.")
        self.RecipientVault = RecipientSimpleFTPackage.borrowVaultPublic(tenantID: SimpleFTTenant.id)
    }

    execute {
        self.RecipientVault.deposit(vault: <- self.SimpleFTMinter.mintTokens(amount: amount))
        log("Deposited newly minted FTs to recipient's Vault.")
    }
}

