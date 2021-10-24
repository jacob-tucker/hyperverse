import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"

pub contract SimpleFT: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub var totalTenants: UInt64

    // tenantID -> @Tenant{IState}
    access(contract) var tenants: @{UInt64: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: UInt64): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    // All of the getters and setters.
    // ** Setters MUST be access(contract) or access(account) **
    pub resource interface IState {
        pub let id: UInt64
        access(contract) fun updateTotalSupply(delta: Fix64)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let id: UInt64 
        pub var holder: Address
        pub var totalSupply: UFix64
        pub fun updateTotalSupply(delta: Fix64) {
            self.totalSupply = UFix64(Fix64(self.totalSupply) + delta)
        }

        init(_tenantID: UInt64, _holder: Address) {
            self.id = _tenantID
            self.holder = _holder
            self.totalSupply = 0.0
        }
    }
    // Returns a Tenant.
    pub fun instance(package: &Package): UInt64 {
        let tenantID = SimpleFT.totalTenants
        SimpleFT.totalTenants = SimpleFT.totalTenants + (1 as UInt64)
        SimpleFT.tenants[tenantID] <-! create Tenant(_tenantID: tenantID, _holder: package.owner!.address)
        
        package.depositAdministrator(Administrator: <- create Administrator(tenantID))
        package.depositMinter(Minter: <- create Minter(tenantID))

        return tenantID
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
    // Any things that should be linked to the public
    pub resource interface PackagePublic {
        pub fun borrowVaultPublic(tenantID: UInt64): &Vault{VaultPublic}
    }
    // A Package is so that you can sort all the resources you WILL or MAY recieve 
    // as a part of you interacting with this contract by tenantID.
    //
    // This also removes the need to have a tenantID in every single resource.
    pub resource Package: PackagePublic {
        pub let admins: @{UInt64: Administrator}
        pub let minters: @{UInt64: Minter}
        pub let vaults: @{UInt64: Vault}

        pub fun setup(tenantID: UInt64) {
            self.vaults[tenantID] <-! create Vault(tenantID, _balance: 0.0)
        }

        pub fun depositAdministrator(Administrator: @Administrator) {
            self.admins[Administrator.tenantID] <-! Administrator
        }
        pub fun borrowAdministrator(tenantID: UInt64): &Administrator {
            return &self.admins[tenantID] as &Administrator
        }

        pub fun depositMinter(Minter: @Minter) {
            self.minters[Minter.tenantID] <-! Minter
        }
        pub fun borrowMinter(tenantID: UInt64): &Minter {
            return &self.minters[tenantID] as &Minter
        }
        
        pub fun borrowVault(tenantID: UInt64): &Vault {
            return &self.vaults[tenantID] as &Vault
        }
        pub fun borrowVaultPublic(tenantID: UInt64): &Vault{VaultPublic} {
            return &self.vaults[tenantID] as &Vault{VaultPublic}
        }

        init() {
            self.admins <- {}
            self.minters <- {}
            self.vaults <- {}
        }

        destroy() {
            destroy self.admins
            destroy self.minters
            destroy self.vaults
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

        init(_ tenantID: UInt64, _balance: UFix64) {
            post {
                self.balance == _balance:
                    "Balance must be initialized to the initial balance"
            }
        }
    }

    pub resource Vault: VaultPublic {
        pub let tenantID: UInt64
        pub var balance: UFix64

        pub fun withdraw(amount: UFix64): @SimpleFT.Vault {
            self.balance = self.balance - amount
            return <-create Vault(self.tenantID, _balance: amount)
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

        init(_ tenantID: UInt64, _balance: UFix64, ) {
            self.balance = _balance
            self.tenantID = tenantID

            SimpleFT.getTenant(id: self.tenantID).updateTotalSupply(delta: Fix64(_balance))
        }

        destroy() {
            SimpleFT.getTenant(id: self.tenantID).updateTotalSupply(delta: -Fix64(self.balance))
        }
    }

    pub resource Administrator {
        pub let tenantID: UInt64

        pub fun createNewMinter(): @Minter {
            return <-create Minter(self.tenantID)
        }
        init(_ tenantID: UInt64) {
            self.tenantID = tenantID
        }
    }

    pub resource Minter {
        pub let tenantID: UInt64
        
        pub fun mintTokens(amount: UFix64): @Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero."
            }
            return <-create Vault(self.tenantID, _balance: amount)
        }
        init(_ tenantID: UInt64) {
           self.tenantID = tenantID
        }
    }

    init() {
        self.totalTenants = 0
        self.tenants <- {}

        // Set our named paths
        self.PackageStoragePath = /storage/SimpleFTPackage
        self.PackagePrivatePath = /private/SimpleFTPackage
        self.PackagePublicPath = /public/SimpleFTPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleFT", 
            _authors: [HyperverseModule.Author(_address: 0x1, _externalLink: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )
    }
}