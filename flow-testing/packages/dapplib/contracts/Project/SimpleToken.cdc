import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import HFungibleToken from "../Hyperverse/HFungibleToken.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract SimpleToken: IHyperverseComposable, HFungibleToken {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    pub fun clientTenantID(account: Address): String {
        return account.toString().concat(".").concat(self.getType().identifier)
    }
    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun getTenant(account: Address): &Tenant{IHyperverseComposable.ITenant, IState} {
        let ref = &self.tenants[self.clientTenantID(account: account)] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
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
        let tenant = auth.owner!.address
        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)
        
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: tenant, _initialSupply: initialSupply)
        
        let package = auth.packages[self.getType().identifier]!.borrow()! as! &Package
        package.depositAdministrator(Administrator: <- create Administrator(tenant))
        package.depositMinter(Minter: <- create Minter(tenant))
        
        emit TenantCreated(id: STenantID)
        emit TokensInitialized(tenant: tenant, initialSupply: initialSupply)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
 
    pub resource interface PackagePublic {
        pub fun borrowVaultPublic(tenant: Address): &Vault{VaultPublic}
        pub fun depositMinter(Minter: @Minter)
        pub fun depositAdministrator(Administrator: @Administrator)
    }

    pub resource Package: PackagePublic {
        pub var vaults: @{Address: HFungibleToken.Vault}
        pub var minters: @{Address: Minter}
        pub var admins: @{Address: Administrator}

        pub fun borrowVault(tenant: Address): &Vault {
            if self.vaults[tenant] == nil {
                self.vaults[tenant] <-! create Vault(tenant, _balance: 0.0)
            }
            let ref = &self.vaults[tenant] as auth &HFungibleToken.Vault
            return ref as! &Vault
        }
        pub fun borrowVaultPublic(tenant: Address): &Vault{VaultPublic} {
            return self.borrowVault(tenant: tenant)
        }

        pub fun depositMinter(Minter: @Minter) {
            self.minters[Minter.tenant] <-! Minter
        }
        pub fun borrowMinter(tenant: Address): &Minter {
            return &self.minters[tenant] as &Minter
        }

        pub fun depositAdministrator(Administrator: @Administrator) {
            self.admins[Administrator.tenant] <-! Administrator
        }
        pub fun borrowAdministrator(tenant: Address): &Administrator {
            return &self.admins[tenant] as &Administrator
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

    pub event TokensInitialized(tenant: Address, initialSupply: UFix64)

    pub event TokensWithdrawn(tenant: Address, amount: UFix64, from: Address?)

    pub event TokensDeposited(tenant: Address, amount: UFix64, to: Address?)

    pub resource interface VaultPublic {
        pub let tenant: Address
        pub var balance: UFix64
        pub fun deposit(from: @HFungibleToken.Vault)

        init(_ tenant: Address, _balance: UFix64) {
            post {
                self.balance == _balance:
                    "Balance must be initialized to the initial balance"
            }
        }
    }

    pub resource Vault: HFungibleToken.Provider, HFungibleToken.Receiver, HFungibleToken.Balance, VaultPublic {
        pub let tenant: Address
        pub var balance: UFix64

        pub fun withdraw(amount: UFix64): @HFungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(tenant: self.tenant, amount: amount, from: self.owner?.address)
            return <-create Vault(self.tenant, _balance: amount)
        }

        pub fun deposit(from: @HFungibleToken.Vault) {
            let vault <- from as! @Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(tenant: self.tenant, amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        init(_ tenant: Address, _balance: UFix64) {
            self.balance = _balance
            self.tenant = tenant

            SimpleToken.getTenant(account: self.tenant).updateTotalSupply(delta: Fix64(_balance))
        }

        destroy() {
            SimpleToken.getTenant(account: self.tenant).updateTotalSupply(delta: -Fix64(self.balance))
        }
    }

    pub resource Administrator {
        pub let tenant: Address

        pub fun createNewMinter(): @Minter {
            return <-create Minter(self.tenant)
        }
        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }

    pub resource Minter {
        pub let tenant: Address
        
        pub fun mintTokens(amount: UFix64): @Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero."
            }
            return <-create Vault(self.tenant, _balance: amount)
        }
        init(_ tenant: Address) {
           self.tenant = tenant
        }
    }

    init() {
        self.tenants <- {}

        self.PackageStoragePath = /storage/SimpleTokenPackage
        self.PackagePrivatePath = /private/SimpleTokenPackage
        self.PackagePublicPath = /public/SimpleTokenPackage

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "SimpleToken", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalLink: "",
                _secondaryModules: nil
            )
        )
    }
}