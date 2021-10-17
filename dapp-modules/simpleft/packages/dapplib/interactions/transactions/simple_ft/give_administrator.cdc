import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

transaction() {
    let SimpleFTTenant: &SimpleFT.Tenant
    let Package: &SimpleFT.Package
    let SimpleFTCapability: Capability<&SimpleFT.Tenant{SimpleFT.IState}>
    
    prepare(signer: AuthAccount, recipient: AuthAccount) {
        self.SimpleFTTenant = signer.borrow<&SimpleFT.Tenant>(from: SimpleFT.getMetadata().tenantStoragePath)!
        self.Package = recipient.borrow<&SimpleFT.Package>(from: /storage/SimpleFTPackage)!
        self.SimpleFTCapability = getAccount(signer.address).getCapability<&SimpleFT.Tenant{SimpleFT.IState}>(SimpleFT.getMetadata().tenantPublicPath)
    }

    execute {
        self.Package.depositAdministrator(Administrator: <- self.SimpleFTTenant.createAdministrator(tenantCapability: self.SimpleFTCapability))
        log("Gave a SimpleFT.Administrator to the recipient's account.")
    }
}

