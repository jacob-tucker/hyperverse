import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import HFungibleToken from "../Hyperverse/HFungibleToken.cdc"

pub contract SimpleToken: IHyperverseModule, IHyperverseComposable, HFungibleToken {

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
        access(contract) fun updateTotalSupply(delta: Fix64)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address
        pub var totalSupply: UFix64
        pub fun updateTotalSupply(delta: Fix64) {
            self.totalSupply = UFix64(Fix64(self.totalSupply) + delta)
        }

        init(_tenantID: String, _holder: Address, _initialSupply: UFix64) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.totalSupply = _initialSupply
        }
    }

    pub fun instance(auth: &HyperverseAuth.Auth, initialSupply: UFix64) {
        pre {
            self.clientTenants[auth.owner!.address] == nil: "This account already have a Tenant from this contract."
        }

        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)
        
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: auth.owner!.address, _initialSupply: initialSupply)
        self.addAlias(auth: auth, new: STenantID)
        
        let package = auth.packages[self.getType().identifier]!.borrow()! as! &Package
        package.depositAdministrator(Administrator: <- create Administrator(STenantID))
        package.depositMinter(Minter: <- create Minter(STenantID))
        
        self.clientTenants[auth.owner!.address] = STenantID
        emit TenantCreated(id: STenantID)
        emit TokensInitialized(tenantID: STenantID, initialSupply: initialSupply)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
 
    pub resource interface PackagePublic {
        pub fun borrowVaultPublic(tenantID: String): &Vault{VaultPublic}
        pub fun depositMinter(Minter: @Minter)
        pub fun depositAdministrator(Administrator: @Administrator)
    }

    pub resource Package: PackagePublic {
        pub var vaults: @{String: HFungibleToken.Vault}
        pub var minters: @{String: Minter}
        pub var admins: @{String: Administrator}

        pub fun borrowVault(tenantID: String): &Vault {
            let original = SimpleToken.aliases[tenantID]!
            if self.vaults[original] == nil {
                self.vaults[original] <-! create Vault(tenantID, _balance: 0.0)
            }
            let ref = &self.vaults[original] as auth &HFungibleToken.Vault
            return ref as! &Vault
        }
        pub fun borrowVaultPublic(tenantID: String): &Vault{VaultPublic} {
            return self.borrowVault(tenantID: tenantID)
        }

        pub fun depositMinter(Minter: @Minter) {
            self.minters[Minter.tenantID] <-! Minter
        }
        pub fun borrowMinter(tenantID: String): &Minter {
            return &self.minters[SimpleToken.aliases[tenantID]!] as &Minter
        }

        pub fun depositAdministrator(Administrator: @Administrator) {
            self.admins[Administrator.tenantID] <-! Administrator
        }
        pub fun borrowAdministrator(tenantID: String): &Administrator {
            return &self.admins[SimpleToken.aliases[tenantID]!] as &Administrator
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

    pub event TokensInitialized(tenantID: String, initialSupply: UFix64)

    pub event TokensWithdrawn(tenantID: String, amount: UFix64, from: Address?)

    pub event TokensDeposited(tenantID: String, amount: UFix64, to: Address?)

    pub resource interface VaultPublic {
        pub let tenantID: String
        pub var balance: UFix64
        pub fun deposit(from: @HFungibleToken.Vault)

        init(_ tenantID: String, _balance: UFix64) {
            post {
                self.balance == _balance:
                    "Balance must be initialized to the initial balance"
            }
        }
    }

    pub resource Vault: HFungibleToken.Provider, HFungibleToken.Receiver, HFungibleToken.Balance, VaultPublic {
        pub let tenantID: String
        pub var balance: UFix64

        pub fun withdraw(amount: UFix64): @HFungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(tenantID: self.tenantID, amount: amount, from: self.owner?.address)
            return <-create Vault(self.tenantID, _balance: amount)
        }

        pub fun deposit(from: @HFungibleToken.Vault) {
            let vault <- from as! @Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(tenantID: self.tenantID, amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        init(_ tenantID: String, _balance: UFix64) {
            self.balance = _balance
            self.tenantID = tenantID

            SimpleToken.getTenant(id: self.tenantID).updateTotalSupply(delta: Fix64(_balance))
        }

        destroy() {
            SimpleToken.getTenant(id: self.tenantID).updateTotalSupply(delta: -Fix64(self.balance))
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

        self.PackageStoragePath = /storage/SimpleTokenPackage
        self.PackagePrivatePath = /private/SimpleTokenPackage
        self.PackagePublicPath = /public/SimpleTokenPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleToken", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: nil
        )
    }
}