import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract HelloWorld {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(tenant: Address)
    
    access(contract) var tenants: @{Address: Tenant}
    access(contract) fun getTenant(_ tenant: Address): &Tenant {
        return &self.tenants[tenant] as &Tenant
    }
    pub fun tenantExists(tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant {
        pub var tenant: Address
        pub let greeting: String

        init(_ tenant: Address) {
            self.tenant = tenant

            self.greeting = "Hello, World! :D"
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        self.tenants[tenant] <-! create Tenant(tenant)
        emit TenantCreated(tenant: tenant)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event HelloWorldInitialized()

    pub fun getGreeting(_ tenant: Address): String {
        return self.getTenant(tenant).greeting
    }

    init() {
        self.tenants <- {}

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