import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"

pub contract SimpleNFT: IHyperverseModule, IHyperverseComposable {

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    pub var totalTenants: UInt64

    // ** MUST be access(contract) **
    access(contract) var clientTenants: {Address: UInt64}
    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    // All of the getters and setters.
    // ** Setters MUST be access(contract) or access(account) **
    pub resource interface IState {
        pub let id: UInt64
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }
    pub resource Tenant: IHyperverseComposable.ITenantID, IState {
        pub let id: UInt64
        pub var totalSupply: UInt64
        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }

        // Store Tenant in account storage first, then do this.
        pub fun createNewMinter(): @NFTMinter {
            return <- create NFTMinter(_tenantID: self.id)
        }

        init(_tenantID: UInt64) {
            self.id = _tenantID
            self.totalSupply = 0
        }
    }
    // Returns a package of things that would normally be saved to account storage
    // in a normal contract.
    pub fun instance(): @Tenant {
        let tenantID = SimpleNFT.totalTenants
        SimpleNFT.totalTenants = SimpleNFT.totalTenants + (1 as UInt64)
        return <- create Tenant(_tenantID: tenantID)
    }

    /* Functionality of the SimpleNFT Module */

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    pub resource NFT {
        pub let id: UInt64
        pub let tenantID: UInt64
        pub let name: String
    
        init(_tenant: &Tenant{IState}, _name: String) {
            self.id = _tenant.totalSupply
            self.tenantID = _tenant.id
            self.name = _name

            _tenant.updateTotalSupply()
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
        pub let tenantID: UInt64
    }

    pub resource Collection: CollectionPublic {
        pub var ownedNFTs: @{UInt64: NFT}
        pub let tenantID: UInt64

        pub fun deposit(token: @NFT) {
            if self.tenantID != token.tenantID {
                panic("This token is from another Tenant and cannot be stored in this collection")
            }

            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }

        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NFT {
            return &self.ownedNFTs[id] as &NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }

        init (_tenantID: UInt64) {
            self.ownedNFTs <- {}
            self.tenantID = _tenantID
        }
    }

    pub fun createEmptyCollection(tenantID: UInt64): @Collection {
        return <- create Collection(_tenantID: tenantID)
    }

    pub resource NFTMinter {
        pub let tenantID: UInt64
        pub fun mintNFT(tenant: &Tenant{IState}, name: String): @NFT {
            return <- create NFT(_tenant: tenant, _name: name)
        }

        init(_tenantID: UInt64) {
            self.tenantID = _tenantID
        }
    }

    init() {
        self.totalTenants = 0
        self.clientTenants = {}

         // Set our named paths
        self.CollectionStoragePath = /storage/SimpleNFTCollection
        self.CollectionPublicPath = /public/SimpleNFTCollection

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleNFT", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalURI: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _tenantStoragePath: /storage/SimpleNFTTenant,
            _tenantPublicPath: /public/SimpleNFTTenant,
            _externalURI: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )

         emit ContractInitialized()
    }
}
 