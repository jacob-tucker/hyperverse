import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"

pub contract SimpleNFT: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    // All the TenantIDs associated with an account
    // The first one is always the non-dependent Tenant
    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String] {
        return self.clientTenants[account]!
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    pub resource interface IState {
        pub let tenantID: String
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address
        pub var totalSupply: UInt64
        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.totalSupply = 0
        }
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
        pub fun borrowCollectionPublic(tenantID: String): &Collection{CollectionPublic}
    }

    pub resource Package: PackagePublic {
        pub var collections: @{String: Collection}
        pub var admins: @{String: Admin}
        pub var minters: @{String: NFTMinter}

        // `instance` takes in a tenantID, which is the `uuid` field of a 
        // IHyperverseComposable.Package. You could cheat the system,
        // but that would only inconveniance you.
        pub fun instance(tenantID: UInt64) {
            var tenantID: String = self.owner!.address.toString().concat(".").concat(tenantID.toString())
            SimpleNFT.tenants[tenantID] <-! create Tenant(_tenantID: tenantID, _holder: self.owner!.address)
            self.depositAdmin(Admin: <- create Admin(tenantID))
            self.depositMinter(NFTMinter: <- create NFTMinter(tenantID))
            emit TenantCreated(id: tenantID)

            if SimpleNFT.clientTenants[self.owner!.address] != nil {
                SimpleNFT.clientTenants[self.owner!.address]!.append(tenantID)
            } else {
                SimpleNFT.clientTenants[self.owner!.address] = [tenantID]
            }
            
        }

        pub fun setup(tenantID: String) {
            self.collections[tenantID] <-! create Collection(tenantID)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenantID] <-! Admin
        }

        pub fun borrowAdmin(tenantID: String): &Admin {
            return &self.admins[tenantID] as &Admin
        }

        pub fun depositMinter(NFTMinter: @NFTMinter) {
            self.minters[NFTMinter.tenantID] <-! NFTMinter
        }

         pub fun borrowMinter(tenantID: String): &NFTMinter {
            return &self.minters[tenantID] as &NFTMinter
        }

        pub fun borrowCollection(tenantID: String): &Collection {
            return &self.collections[tenantID] as &Collection
        }

        pub fun borrowCollectionPublic(tenantID: String): &Collection{CollectionPublic} {
            pre {
                self.collections[tenantID] != nil: "It's nil."
            }
            return &self.collections[tenantID] as &Collection{CollectionPublic}
        }

        init() {
            self.collections <- {}
            self.admins <- {}
            self.minters <- {}
        }

        destroy() {
            destroy self.collections
            destroy self.admins
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
        pub let tenantID: String
        pub let id: UInt64
        pub var metadata: {String: String}
    
        init(_ tenantID: String, _metadata: {String: String}) {
            let tenant = SimpleNFT.getTenant(id: tenantID)
          
            self.id = tenant.totalSupply
            self.tenantID = tenantID
            self.metadata = _metadata

            tenant.updateTotalSupply()
        }
    }

    pub resource interface CollectionPublic {
        pub let tenantID: String
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
    }

    pub resource Collection: CollectionPublic {
        pub let tenantID: String

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

        init (_ tenantID: String) {
            self.tenantID = tenantID
            self.ownedNFTs <- {}
        }
    }

    pub resource Admin {
        pub let tenantID: String
        pub fun createNFTMinter(): @NFTMinter {
            return <- create NFTMinter(self.tenantID)
        }
        init(_ tenantID: String) {
            self.tenantID = tenantID
        }
    }

    pub resource NFTMinter {
        pub let tenantID: String
        pub fun mintNFT(metadata: {String: String}): @NFT {
            return <- create NFT(self.tenantID, _metadata: metadata)
        }
        init(_ tenantID: String) {
            self.tenantID = tenantID
        }
    }

    init() {
        self.clientTenants = {}
        self.tenants <- {}

         // Set our named paths
        self.PackageStoragePath = /storage/SimpleNFTPackage
        self.PackagePrivatePath = /private/SimpleNFTPackage
        self.PackagePublicPath = /public/SimpleNFTPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleNFT", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalURI: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalURI: "",
            _secondaryModules: nil
        )

         emit ContractInitialized()
    }
}
 