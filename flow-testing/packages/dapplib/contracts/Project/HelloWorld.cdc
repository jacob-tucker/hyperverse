import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract HelloWorld: IHyperverseComposable {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    pub fun clientTenantID(account: Address): String {
        return account.toString().concat(".").concat(self.getType().identifier)
    }
    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun tenantExists(account: Address): Bool {
        return self.tenants[self.clientTenantID(account: account)] != nil
    }
    pub fun getTenant(account: Address): &Tenant{IHyperverseComposable.ITenant, IState} {
        let ref = &self.tenants[self.clientTenantID(account: account)] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }

    pub resource interface IState {
        pub let tenantID: String
        pub var holder: Address

        pub let greeting: String
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        pub let greeting: String

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder

            self.greeting = "Hello, World! :D"
        }
    }

    pub fun instance(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        var STenantID: String = self.clientTenantID(account: tenant)
        
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: tenant)
        
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
        self.tenants <- {}
        self.PackageStoragePath = /storage/HelloWorldPackage
        self.PackagePrivatePath = /private/HelloWorldPackage
        self.PackagePublicPath = /public/HelloWorldPackage

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