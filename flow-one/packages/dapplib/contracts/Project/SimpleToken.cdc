import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import HFungibleToken from "../Hyperverse/HFungibleToken.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract SimpleToken {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(tenant: Address)
    
    access(contract) var tenants: @{Address: Tenant}
    access(contract) fun getTenant(_ tenant: Address): &Tenant {
        return &self.tenants[tenant] as &Tenant
    }
    pub fun tenantExists(_ tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant {
        pub var tenant: Address
        pub(set) var totalSupply: UFix64

        init(_ tenant: Address, _initialSupply: UFix64) {
            self.tenant = tenant
            self.totalSupply = _initialSupply
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth, initialSupply: UFix64) {
        let tenant = auth.owner!.address
        self.tenants[tenant] <-! create Tenant(tenant, _initialSupply: initialSupply)
        emit TenantCreated(tenant: tenant)
        emit TokensInitialized(tenant: tenant, initialSupply: initialSupply)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event TokensInitialized(tenant: Address, initialSupply: UFix64)
    pub event TokensWithdrawn(tenant: Address, amount: UFix64, from: Address?)
    pub event TokensDeposited(tenant: Address, amount: UFix64, to: Address?)

    pub resource interface VaultPublic {
        pub fun deposit(from: @VaultTransferrable)
        pub fun balance(_ tenant: Address): UFix64
    }

    pub struct VaultData {
        pub(set) var balance: UFix64 
        init(_balance: UFix64) { self.balance = _balance }
    }

    pub let VaultStoragePath: StoragePath
    pub let VaultPublicPath: PublicPath
    pub resource Vault: VaultPublic {
        access(contract) var datas: {Address: VaultData}
        access(contract) fun getData(_ tenant: Address): &VaultData {
            if self.datas[tenant] == nil { self.datas[tenant] = VaultData(_balance: 0.0) }
            return &self.datas[tenant] as &VaultData 
        }

        pub fun withdraw(_ tenant: Address, amount: UFix64): @VaultTransferrable {
            let data = self.getData(tenant)
            data.balance = data.balance - amount
            emit TokensWithdrawn(tenant: tenant, amount: amount, from: self.owner?.address)

            return <- create VaultTransferrable(tenant, _balance: amount)
        }

        pub fun deposit(from: @VaultTransferrable) {
            let vault <- from as! @VaultTransferrable
            let data = self.getData(vault.tenant)
            data.balance = data.balance + vault.balance
            emit TokensDeposited(tenant: vault.tenant, amount: vault.balance, to: self.owner?.address)

            vault.clear()
            destroy vault
        }

        pub fun balance(_ tenant: Address): UFix64 { return self.getData(tenant).balance }

        init() { 
            self.datas = {}
        }

        destroy() {
            for tenant in self.datas.keys {
                let state = SimpleToken.getTenant(tenant)
                state.totalSupply = state.totalSupply - self.balance(tenant)
            }
        }
    }

    pub resource VaultTransferrable {
        pub var balance: UFix64 
        pub let tenant: Address
        access(contract) fun clear() {self.balance = 0.0}
        init(_ tenant: Address, _balance: UFix64) {
            self.balance = _balance
            self.tenant = tenant
        }
        destroy() {
            let state = SimpleToken.getTenant(self.tenant)
            state.totalSupply = state.totalSupply - self.balance
        }
    }

    pub fun createEmptyVault(): @Vault { return <- create Vault() }

    pub let MinterStoragePath: StoragePath
    pub resource Minter {
        access(contract) var tenants: {Address: Bool}
        access(contract) fun addTenant(_ tenant: Address) { self.tenants[tenant] = true }
        pub fun mintTokens(_ tenant: Address, amount: UFix64): @VaultTransferrable {
            pre {
                amount > 0.0: "Amount minted must be greater than zero."
                self.tenants[tenant]!: "You are not permissioned to do this"
            }
            let state = SimpleToken.getTenant(tenant)
            state.totalSupply = state.totalSupply + amount

            return <- create VaultTransferrable(tenant, _balance: amount)
        }
        init() { self.tenants = {} }
    }

    pub fun createMinter(): @Minter { return <- create Minter() }

    pub let AdminStoragePath: StoragePath
     pub resource Admin {
        pub let tenant: Address
        pub fun permissionMinter(minter: &Minter) { minter.addTenant(self.tenant) }
        init(_ tenant: Address) { self.tenant = tenant }
    }

    pub fun createAdmin(auth: &HyperverseAuth.Auth): @Admin { return <- create Admin(auth.owner!.address) }

    pub fun getTotalSupply(tenant: Address): UFix64 { return self.getTenant(tenant).totalSupply }

    init() {
        self.tenants <- {}

        self.VaultStoragePath = /storage/SimpleTokenVault
        self.VaultPublicPath = /public/SimpleTokenVault
        self.MinterStoragePath = /storage/SimpleTokenMinter
        self.AdminStoragePath = /storage/SimpleTokenAdmin

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