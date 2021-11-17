import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"

pub contract HelloWorld: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    access(contract) var clientTenants: {Address: String}
    pub fun getClientTenantID(account: Address): String? {
        return self.clientTenants[account]
    }
    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        let ref = &self.tenants[id] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    access(contract) var aliases: {String: String}
    pub fun addAlias(auth: &HyperverseAuth.Auth, new: String) {
        let original = auth.owner!.address.toString()
                        .concat(".")
                        .concat(self.getType().identifier)

        self.aliases[new] = original
    }

    pub resource interface IState {
        pub let tenantID: String
        pub var holder: Address
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
        }
    }

    pub fun instance(auth: &HyperverseAuth.Auth) {
        pre {
            self.clientTenants[auth.owner!.address] == nil: "This account already have a Tenant from this contract."
        }

        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)
        
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: auth.owner!.address)
        self.addAlias(auth: auth, new: STenantID)
        
        self.clientTenants[auth.owner!.address] = STenantID
        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/
    
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
    pub resource Package {}

    /**************************************** FUNCTIONALITY ****************************************/

    pub event HelloWorldInitialized()

    init() {
        self.clientTenants = {}
        self.tenants <- {}
        self.aliases = {}
        self.PackageStoragePath = /storage/HelloWorldPackage
        self.PackagePrivatePath = /private/HelloWorldPackage
        self.PackagePublicPath = /public/HelloWorldPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "HelloWorld", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: nil
        )

        emit HelloWorldInitialized()
    }
}