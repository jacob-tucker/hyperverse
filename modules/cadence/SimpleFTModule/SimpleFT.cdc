import HyperverseService from "../HyperverseService.cdc"
import IHyperverseComposable from "../IHyperverseComposable.cdc"
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract SimpleFT: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    pub var totalTenants: UInt64

    // All of the getters and setters.
    // ** Setters MUST be access(contract) or access(account) **
    pub resource interface IState {
        pub let id: UInt64
        access(contract) fun updateTotalSupply(delta: Fix64)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenantID, IState {
        pub let id: UInt64 
        pub var totalSupply: UFix64
        pub fun updateTotalSupply(delta: Fix64) {
            self.totalSupply = UFix64(Fix64(self.totalSupply) + delta)
        }
        pub fun createVault(tenantCapability: Capability<&Tenant{IState}>): @Vault {
            return <- create Vault(_tenantID: self.id, _tenantCapability: tenantCapability, _balance: 0.0)
        }
        pub fun createAdministrator(tenantCapability: Capability<&Tenant{IState}>): @Administrator {
            return <- create Administrator(_tenantID: self.id, _tenantCapability: tenantCapability)
        }

        init(_tenantID: UInt64) {
            self.id = _tenantID
            self.totalSupply = 0.0
        }
    }
    // Returns a Tenant.
    pub fun instance(): @Tenant {
        let tenantID = SimpleFT.totalTenants
        SimpleFT.totalTenants = SimpleFT.totalTenants + (1 as UInt64)
        return <- create Tenant(_tenantID: tenantID)
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePublicPath: PublicPath
    // Any things that should be linked to the public
    pub resource interface PackagePublic {
        
    }
    // A Package is so that you can sort all the resources you WILL or MAY recieve 
    // as a part of you interacting with this contract by tenantID.
    //
    // This also removes the need to have a tenantID in every single resource.
    pub resource Package: PackagePublic {
        pub let admins: @{UInt64: Administrator}
        pub let minters: @{UInt64: Minter}

        // Maybe have a map of tenantID: Capability<&Tenant{IState}> ??????

        pub fun depositAdministrator(Administrator: @Administrator) {
            self.admins[Administrator.tenantID] <-! Administrator
        }

        pub fun depositMinter(Minter: @Minter) {
            self.minters[Minter.tenantID] <-! Minter
        }

        pub fun borrowAdministrator(tenantID: UInt64): &Administrator {
            return &self.admins[tenantID] as &Administrator
        }

        pub fun borrowMinter(tenantID: UInt64): &Minter {
            return &self.minters[tenantID] as &Minter
        }

        init() {
            self.admins <- {}
            self.minters <- {}
        }

        destroy() {
            destroy self.admins
            destroy self.minters
        }
    }

    pub fun getPackage(): @Package {
        return <- create Package()
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub resource interface VaultPublic {
        pub let tenantID: UInt64
        pub var balance: UFix64
        pub fun deposit(vault: @Vault)

        init(_tenantID: UInt64, _tenantVaultRef: Capability<&Tenant{IState}>, _balance: UFix64) {
            post {
                self.balance == _balance:
                    "Balance must be initialized to the initial balance"
            }
        }
    }

    pub resource Vault: VaultPublic {
        pub let tenantID: UInt64
        pub let tenantCapability: Capability<&Tenant{IState}>
        pub var balance: UFix64

        pub fun withdraw(amount: UFix64): @SimpleFT.Vault {
            self.balance = self.balance - amount
            return <-create Vault(_tenantID: self.tenantID, _tenantCapability: self.tenantCapability, _balance: amount)
        }

        pub fun deposit(vault: @Vault) {
            // Makes sure that the tokens being deposited are from the
            // same Tenant. That's why we need the Tenant's id.
            pre {
                vault.tenantID == self.tenantID:
                    "Trying to deposit SimpleFT that belongs to another Tenant"
            }
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }

        init(_tenantID: UInt64, _tenantCapability: Capability<&Tenant{IState}>, _balance: UFix64, ) {
            self.balance = _balance
            self.tenantID = _tenantID
            self.tenantCapability = _tenantCapability

            _tenantCapability.borrow()!.updateTotalSupply(delta: Fix64(_balance))
        }

        destroy() {
            self.tenantCapability.borrow()!.updateTotalSupply(delta: -Fix64(self.balance))
        }
    }

    pub resource Administrator {
        pub let tenantID: UInt64
        pub let tenantCapability: Capability<&Tenant{IState}>
        pub fun createNewMinter(): @Minter {
            return <-create Minter(_tenantID: self.tenantID, _tenantCapability: self.tenantCapability)
        }
        init(_tenantID: UInt64, _tenantCapability: Capability<&Tenant{IState}>) {
            self.tenantID = _tenantID
            self.tenantCapability = _tenantCapability
        }
    }

    pub resource Minter {
        pub let tenantID: UInt64
        pub let tenantCapability: Capability<&Tenant{IState}>
        pub fun mintTokens(amount: UFix64): @Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero."
            }
            return <-create Vault(_tenantID: self.tenantID, _tenantCapability: self.tenantCapability, _balance: amount)
        }
        init(_tenantID: UInt64, _tenantCapability: Capability<&Tenant{IState}>) {
           self.tenantID = _tenantID
           self.tenantCapability = _tenantCapability
        }
    }

    init() {
        self.totalTenants = 0

        // Set our named paths
        self.PackageStoragePath = /storage/SimpleFTPackage
        self.PackagePublicPath = /public/SimpleFTPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleFT", 
            _authors: [HyperverseModule.Author(_address: 0x1, _externalLink: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _tenantStoragePath: /storage/SimpleFTTenant,
            _tenantPublicPath: /public/SimpleFTTenant,
            _externalLink: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )
    }
}