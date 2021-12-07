import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import HNonFungibleToken from "../Hyperverse/HNonFungibleToken.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract SimpleNFT {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(tenant: Address)
    
    access(contract) var tenants: @{Address: Tenant}
    access(contract) fun getTenant(tenant: Address): &Tenant {
        if self.tenants[tenant] == nil {
            self.tenants[tenant] <-! create Tenant(_tenant: tenant)
            emit TenantCreated(tenant: tenant)
        }
        return &self.tenants[tenant] as &Tenant
    }
    pub fun tenantExists(tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }

    pub resource Tenant {
        pub var tenant: Address
        pub(set) var totalSupply: UInt64
        
        init(_tenant: Address) {
            self.totalSupply = 0
            self.tenant = _tenant
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        self.tenants[tenant] <-! create Tenant(_tenant: tenant)
        emit TenantCreated(tenant: tenant)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event ContractInitialized()
    pub event Withdraw(tenant: Address, id: UInt64, from: Address?)
    pub event Deposit(tenant: Address, id: UInt64, to: Address?)

    pub resource NFT: HNonFungibleToken.INFT {
        pub let tenant: Address
        pub let id: UInt64
        pub var metadata: {String: String}
    
        init(_ tenant: Address, _metadata: {String: String}) {
            self.id = self.uuid
            self.tenant = tenant
            self.metadata = _metadata

            let state = SimpleNFT.getTenant(tenant: tenant)
            state.totalSupply = state.totalSupply + 1
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(tenant: Address, token: @NFT)
        pub fun getIDs(tenant: Address): [UInt64]
        // pub fun getMetadata(tenant: Address, id: UInt64): {String: String}
    }

    pub resource CollectionData {
        pub(set) var ownedNFTs: @{UInt64: NFT}
        init() { self.ownedNFTs <- {} }
        destroy() {destroy self.ownedNFTs}
    }

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub resource Collection: CollectionPublic {
        access(contract) var datas: @{Address: CollectionData}
        access(contract) fun getData(_ tenant: Address): &CollectionData {
            if self.datas[tenant] == nil { self.datas[tenant] <-! create CollectionData() }
            return &self.datas[tenant] as &CollectionData 
        }

        pub fun deposit(tenant: Address, token: @NFT) {
            let token <- token as! @NFT
            let id: UInt64 = token.id

            let data = self.getData(tenant)
            let oldToken <- data.ownedNFTs[id] <- token
            emit Deposit(tenant: tenant, id: id, to: self.owner?.address)
            destroy oldToken
        }

        pub fun withdraw(tenant: Address, withdrawID: UInt64): @NFT {
            let data = self.getData(tenant)
            let token <- data.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(tenant: tenant, id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun getIDs(tenant: Address): [UInt64] {
            let data = self.getData(tenant)
            return data.ownedNFTs.keys
        }

        pub fun borrowNFT(tenant: Address, id: UInt64): &NFT {
            let data = self.getData(tenant)
            return &data.ownedNFTs[id] as &NFT
        }

        // pub fun getMetadata(tenant: Address, id: UInt64): {String: String} {
        //     let data = self.getData(tenant)
        //     let ref = &data.ownedNFTs[id] as auth &HNonFungibleToken.NFT
        //     let wholeNFT = ref as! &NFT
        //     return wholeNFT.metadata
        // }

        destroy() {
            destroy self.datas
        }

        init () {
            self.datas <- {}
        }
    }

    pub fun createEmptyCollection(): @Collection { return <- create Collection() }

    pub let MinterStoragePath: StoragePath
    pub resource Minter {
        access(contract) var tenants: {Address: Bool}
        access(contract) fun addTenant(_ tenant: Address) { self.tenants[tenant] = true }
        pub fun mintNFT(tenant: Address, metadata: {String: String}): @NFT {
            pre { self.tenants[tenant]!: "You are not permissioned to mint NFTs." }
            return <- create NFT(tenant, _metadata: metadata)
        }
        init() { self.tenants = {} }
    }

    pub fun createMinter(): @Minter { return <- create Minter() }

    pub let AdminStoragePath: StoragePath
    pub resource Admin {
        pub let tenant: Address
        pub fun permissionMinter(minter: &Minter) { minter.addTenant(self.tenant) }
        init(_tenant: Address) { self.tenant = _tenant}
    }

    pub fun createAdmin(auth: &HyperverseAuth.Auth): @Admin { return <- create Admin(_tenant: auth.owner!.address) }

    pub fun getTotalSupply(tenant: Address): UInt64 { return self.getTenant(tenant: tenant).totalSupply }

    init() {
        self.tenants <- {}

        self.CollectionStoragePath = /storage/SimpleNFTCollection
        self.CollectionPublicPath = /public/SimpleNFTCollection
        self.MinterStoragePath = /storage/SimpleNFTMinter
        self.AdminStoragePath = /storage/SimpleNFTAdmin

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "SimpleNFT", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalURI: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalURI: "",
                _secondaryModules: nil
            )
        )

         emit ContractInitialized()
    }
}