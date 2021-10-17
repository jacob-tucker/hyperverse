import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

// signer: administrator
// recipient: person getting minter
// tenant: address of the tenant
transaction(tenant: Address) {
    let Administrator: &SimpleFT.Administrator
    let RecipientPackage: &SimpleFT.Package
    
    prepare(signer: AuthAccount, recipient: AuthAccount) {
        let SimpleFTTenant = getAccount(tenant).getCapability(SimpleFT.getMetadata().tenantPublicPath)
                                .borrow<&SimpleFT.Tenant{SimpleFT.IState}>()
                                ?? panic("Could not borrow the tenant.")

        let SignerPackage = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                            ?? panic("Could not borrow the Package from signer's storage.")

        self.Administrator = SignerPackage.borrowAdministrator(tenantID: SimpleFTTenant.id)

        self.RecipientPackage = recipient.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                                    ?? panic("Could not borrow the Package from recipient's storage.")
        
    }

    execute {
        self.RecipientPackage.depositMinter(Minter: <- self.Administrator.createNewMinter())
        log("Gave a SimpleFT.Minter to the recipient's account.")
    }
}

