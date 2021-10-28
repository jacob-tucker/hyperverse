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

    pub event TenantCreated(id: String)
    pub event TenantReused(id: String)
    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String] {
        return self.clientTenants[account]!
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }
    access(contract) var aliases: {String: String}
    access(contract) fun addAlias(original: String, new: String) {
        pre {
            self.tenants[original] != nil: "Original tenantID does not exist."
        }
        self.aliases[new] = original
    }

    pub resource interface IState {
        pub let tenantID: String
        access(contract) fun updateTotalSupply(delta: Fix64)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address
        pub var totalSupply: UFix64
        pub fun updateTotalSupply(delta: Fix64) {
            self.totalSupply = UFix64(Fix64(self.totalSupply) + delta)
        }

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.totalSupply = 0.0
        }
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
 
    pub resource interface PackagePublic {
        pub fun borrowVaultPublic(tenantID: String): &Vault{VaultPublic}
        pub fun depositMinter(Minter: @Minter)
    }

    pub resource Package: PackagePublic {
        pub var admins: @{String: Administrator}
        pub var minters: @{String: Minter}
        pub var vaults: @{String: Vault}

        pub fun instance(tenantIDs: {String: UInt64}) {
            var tenantID: String = self.owner!.address.toString().concat(".").concat(tenantIDs["SimpleFT"]!.toString())
            
            SimpleFT.tenants[tenantID] <-! create Tenant(_tenantID: tenantID, _holder: self.owner!.address)
            SimpleFT.addAlias(original: tenantID, new: tenantID)
            self.depositAdministrator(Administrator: <- create Administrator(tenantID))
            self.depositMinter(Minter: <- create Minter(tenantID))
            emit TenantCreated(id: tenantID)

            if SimpleFT.clientTenants[self.owner!.address] != nil {
                SimpleFT.clientTenants[self.owner!.address]!.append(tenantID)
            } else {
                SimpleFT.clientTenants[self.owner!.address] = [tenantID]
            }
        }

        pub fun addAlias(original: UInt64, new: UInt64) {
            let originalID = self.owner!.address.toString().concat(".").concat(original.toString())
            let newID = self.owner!.address.toString().concat(".").concat(new.toString())
            
            SimpleFT.addAlias(original: originalID, new: newID)
            emit TenantReused(id: originalID)
        }

        pub fun setup(tenantID: String) {
            pre {
                SimpleFT.tenants[tenantID] != nil: "This tenantID does not exist."
            }
            self.vaults[tenantID] <-! create Vault(tenantID, _balance: 0.0)
        }

        pub fun depositAdministrator(Administrator: @Administrator) {
            self.admins[Administrator.tenantID] <-! Administrator
        }
        pub fun borrowAdministrator(tenantID: String): &Administrator {
            return &self.admins[SimpleFT.aliases[tenantID]!] as &Administrator
        }

        pub fun depositMinter(Minter: @Minter) {
            self.minters[Minter.tenantID] <-! Minter
        }
        pub fun borrowMinter(tenantID: String): &Minter {
            return &self.minters[SimpleFT.aliases[tenantID]!] as &Minter
        }
        
        pub fun borrowVault(tenantID: String): &Vault {
            let original = SimpleFT.aliases[tenantID]!
            if self.vaults[original] == nil {
                self.setup(tenantID: original)
            }
            return &self.vaults[original] as &Vault
        }
        pub fun borrowVaultPublic(tenantID: String): &Vault{VaultPublic} {
            return self.borrowVault(tenantID: tenantID)
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
        pub let tenantID: String
        pub var balance: UFix64
        pub fun deposit(vault: @Vault)

        init(_ tenantID: String, _balance: UFix64) {
            post {
                self.balance == _balance:
                    "Balance must be initialized to the initial balance"
            }
        }
    }

    pub resource Vault: VaultPublic {
        pub let tenantID: String
        pub var balance: UFix64

        pub fun withdraw(amount: UFix64): @SimpleFT.Vault {
            self.balance = self.balance - amount
            return <-create Vault(self.tenantID, _balance: amount)
        }

        pub fun deposit(vault: @Vault) {
            pre {
                vault.tenantID == self.tenantID:
                    "Trying to deposit SimpleFT that belongs to another Tenant"
            }
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }

        init(_ tenantID: String, _balance: UFix64, ) {
            self.balance = _balance
            self.tenantID = tenantID

            SimpleFT.getTenant(id: self.tenantID).updateTotalSupply(delta: Fix64(_balance))
        }

        destroy() {
            SimpleFT.getTenant(id: self.tenantID).updateTotalSupply(delta: -Fix64(self.balance))
        }
    }

    pub resource Administrator {
        pub let tenantID: String

        pub fun createNewMinter(): @Minter {
            return <-create Minter(self.tenantID)
        }
        init(_ tenantID: String) {
            self.tenantID = tenantID
        }
    }

    pub resource Minter {
        pub let tenantID: String
        
        pub fun mintTokens(amount: UFix64): @Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero."
            }
            return <-create Vault(self.tenantID, _balance: amount)
        }
        init(_ tenantID: String) {
           self.tenantID = tenantID
        }
    }

    init() {
        self.clientTenants = {}
        self.tenants <- {}
        self.aliases = {}

        self.PackageStoragePath = /storage/SimpleFTPackage
        self.PackagePrivatePath = /private/SimpleFTPackage
        self.PackagePublicPath = /public/SimpleFTPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleFT", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: nil
        )
    }
}