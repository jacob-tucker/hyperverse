import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract HelloWorld: IHyperverseComposable {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(tenant: Address)
    
    access(contract) var tenants: @{Address: IHyperverseComposable.Tenant}
    access(contract) fun getTenant(tenant: Address): &Tenant {
        let ref = &self.tenants[tenant] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    pub fun tenantExists(tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant {
        pub var holder: Address

        pub let greeting: String

        init(_holder: Address) {
            self.holder = _holder

            self.greeting = "Hello, World! :D"
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        
        self.tenants[tenant] <-! create Tenant(_holder: tenant)
        
        emit TenantCreated(tenant: tenant)
    }

    /**************************************** BUNDLE ****************************************/
    
    pub let BundleStoragePath: StoragePath
    pub let BundlePrivatePath: PrivatePath
    pub let BundlePublicPath: PublicPath
    pub resource Bundle {}

    /**************************************** FUNCTIONALITY ****************************************/

    pub event HelloWorldInitialized()

    pub fun getGreeting(tenant: Address): String {
        return self.getTenant(tenant: tenant).greeting
    }

    init() {
        self.tenants <- {}
        self.BundleStoragePath = /storage/HelloWorldBundle
        self.BundlePrivatePath = /private/HelloWorldBundle
        self.BundlePublicPath = /public/HelloWorldBundle

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "HelloWorld", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalLink: "",
                _secondaryModules: nil
            )
        )

        emit HelloWorldInitialized()
    }
}