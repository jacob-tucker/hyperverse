import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"

pub contract SimpleFT: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: UInt64)
    access(contract) var clientTenants: {Address: UInt64}
    pub fun getClientTenants(): {Address: UInt64} {
        return self.clientTenants
    }
    access(contract) var tenants: @{UInt64: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: UInt64): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    pub resource interface IState {
        pub let tenantID: UInt64
        access(contract) fun updateTotalSupply(delta: Fix64)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: UInt64
        pub var holder: Address
        pub var totalSupply: UFix64
        pub fun updateTotalSupply(delta: Fix64) {
            self.totalSupply = UFix64(Fix64(self.totalSupply) + delta)
        }

        init(_tenantID: UInt64, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.totalSupply = 0.0
        }
    }

    pub fun instance(package: &Package, uid: &HyperverseModule.UniqueID): UInt64 {
        pre {
            uid.dependency || SimpleFT.clientTenants[package.owner!.address] == nil:
                "This user already owns a Tenant from this contract!"
        }
        var tenantID: UInt64 = uid.uuid
        let newTenant <- create Tenant(_tenantID: tenantID, _holder: package.owner!.address)
        SimpleFT.tenants[tenantID] <-! newTenant
           package.depositAdministrator(Administrator: <- create Administrator(tenantID))
        package.depositMinter(Minter: <- create Minter(tenantID))
        emit TenantCreated(id: tenantID)

        if !uid.dependency {
            SimpleFT.clientTenants[package.owner!.address] = tenantID
        }
        return tenantID
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
 
    pub resource interface PackagePublic {
        pub fun borrowVaultPublic(tenantID: UInt64): &Vault{VaultPublic}
    }

    pub resource Package: PackagePublic {
        pub var admins: @{UInt64: Administrator}
        pub var minters: @{UInt64: Minter}
        pub var vaults: @{UInt64: Vault}

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
        self.clientTenants = {}
        self.tenants <- {}

        // Set our named paths
        self.PackageStoragePath = /storage/SimpleFTPackage
        self.PackagePrivatePath = /private/SimpleFTPackage
        self.PackagePublicPath = /public/SimpleFTPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleFT", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: nil
        )
    }
}