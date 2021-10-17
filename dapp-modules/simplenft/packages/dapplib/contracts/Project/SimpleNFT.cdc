import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"

pub contract SimpleNFT: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    pub var totalTenants: UInt64

    /**************************************** TENANT ****************************************/

    // All of the getters and setters.
    // ** Setters MUST be access(contract) or access(account) **
    pub resource interface IState {
        pub let id: UInt64
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
        pub fun createCollection(): @Collection
    }
    pub resource Tenant: IHyperverseComposable.ITenantID, IState {
        pub let id: UInt64
        pub var totalSupply: UInt64
        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }
        pub fun createCollection(): @Collection {
            return <- create Collection(_tenantID: self.id)
        }

        pub fun createNewMinter(): @NFTMinter {
            return <- create NFTMinter(_tenantID: self.id)
        }

        init(_tenantID: UInt64) {
            self.id = _tenantID
            self.totalSupply = 0
        }
    }
    // Returns a Tenant.
    pub fun instance(): @Tenant {
        let tenantID = SimpleNFT.totalTenants
        SimpleNFT.totalTenants = SimpleNFT.totalTenants + (1 as UInt64)
        return <- create Tenant(_tenantID: tenantID)
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePublicPath: PublicPath
    // Any things that should be linked to the public
    pub resource interface PackagePublic {
        pub fun borrowCollectionPublic(tenantID: UInt64): &Collection{CollectionPublic}
    }
    // A Package is so that you can sort all the resources you WILL or MAY recieve 
    // as a part of you interacting with this contract by tenantID.
    //
    // This also removes the need to have a tenantID in every single resource.
    pub resource Package: PackagePublic {
        pub let collections: @{UInt64: Collection}
        pub let minters: @{UInt64: NFTMinter}

        pub fun depositCollection(Collection: @Collection) {
            self.collections[Collection.tenantID] <-! Collection
        }

        pub fun depositMinter(NFTMinter: @NFTMinter) {
            self.minters[NFTMinter.tenantID] <-! NFTMinter
        }

        pub fun borrowCollection(tenantID: UInt64): &Collection {
            return &self.collections[tenantID] as &Collection
        }

        pub fun borrowCollectionPublic(tenantID: UInt64): &Collection{CollectionPublic} {
            return &self.collections[tenantID] as &Collection{CollectionPublic}
        }

        pub fun borrowMinter(tenantID: UInt64): &NFTMinter {
            return &self.minters[tenantID] as &NFTMinter
        }

        init() {
            self.collections <- {}
            self.minters <- {}
        }

        destroy() {
            destroy self.collections
            destroy self.minters
        }
    }

    pub fun getPackage(): @Package {
        return <- create Package()
    }

    /**************************************** FUNCTIONALITY ****************************************/

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub resource NFT {
        pub let tenantID: UInt64

        pub let id: UInt64
        pub let name: String
    
        init(_tenant: &Tenant{IState}, _name: String) {
            self.id = _tenant.totalSupply
            self.tenantID = _tenant.id
            self.name = _name

            _tenant.updateTotalSupply()
        }
    }

    pub resource interface CollectionPublic {
        pub let tenantID: UInt64
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
    }

    pub resource Collection: CollectionPublic {
        pub let tenantID: UInt64
        pub var ownedNFTs: @{UInt64: NFT}

        pub fun deposit(token: @NFT) {
            pre {
                self.tenantID == token.tenantID: "This token belongs to a different Tenant."
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
            self.tenantID = _tenantID
            self.ownedNFTs <- {}
        }
    }

    pub resource NFTMinter {
        pub let tenantID: UInt64
        pub fun mintNFT(tenant: &Tenant{IState}, name: String): @NFT {
            pre {
                self.tenantID == tenant.id: "Trying to mint an NFT from a different Tenant."
            }
            return <- create NFT(_tenant: tenant, _name: name)
        }

        init(_tenantID: UInt64) {
            self.tenantID = _tenantID
        }
    }

    init() {
        self.totalTenants = 0

         // Set our named paths
        self.PackageStoragePath = /storage/SimpleNFTPackage
        self.PackagePublicPath = /public/SimpleNFTPackage

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
 