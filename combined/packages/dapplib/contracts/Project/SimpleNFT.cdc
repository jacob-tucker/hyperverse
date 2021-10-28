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
    pub event TenantReused(id: String)
    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String] {
        return self.clientTenants[account]!
    }
    // Original tenantID --> actual resource
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }
    // Alias to original. Original -> actual resource above
    // So if an alias exists, it already points to a Tenant
    access(contract) var aliases: {String: String}
    access(contract) fun addAlias(original: String, new: String) {
        pre {
            self.tenants[original] != nil: "Original tenantID does not exist."
        }
        self.aliases[new] = original
    }

    pub resource interface IState {
        pub let tenantID: String
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }

    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }
        pub var holder: Address

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.totalSupply = 0
            self.holder = _holder
        }
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
        pub fun borrowCollectionPublic(tenantID: String): &Collection{CollectionPublic}
        pub fun depositMinter(NFTMinter: @NFTMinter)
    }

    // All of the getAlias stuff only happens in this Package :)
    pub resource Package: PackagePublic {
        pub var collections: @{String: Collection}
        pub var admins: @{String: Admin}
        pub var minters: @{String: NFTMinter}

        // If we're making a new Tenant resource
        pub fun instance(tenantID: UInt64, modules: {String: UInt64}) {
            var STenantID: String = self.owner!.address.toString().concat(".").concat(tenantID.toString())
        
            SimpleNFT.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: self.owner!.address)
            SimpleNFT.addAlias(original: STenantID, new: STenantID)
            self.depositAdmin(Admin: <- create Admin(STenantID))
            self.depositMinter(NFTMinter: <- create NFTMinter(STenantID))
            emit TenantCreated(id: STenantID)

            if SimpleNFT.clientTenants[self.owner!.address] != nil {
                SimpleNFT.clientTenants[self.owner!.address]!.append(STenantID)
            } else {
                SimpleNFT.clientTenants[self.owner!.address] = [STenantID]
            }
           
        }

        // If we're reusing the Tenant resource
        pub fun addAlias(original: UInt64, new: UInt64) {
            let originalID = self.owner!.address.toString().concat(".").concat(original.toString())
            let newID = self.owner!.address.toString().concat(".").concat(new.toString())
            
            SimpleNFT.addAlias(original: originalID, new: newID)
            emit TenantReused(id: originalID)
        }

        pub fun setup(tenantID: String) {
            pre {
                SimpleNFT.tenants[tenantID] != nil: "This tenantID does not exist."
            }
            self.collections[tenantID] <-! create Collection(tenantID)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenantID] <-! Admin
        }

        pub fun borrowAdmin(tenantID: String): &Admin {
            return &self.admins[SimpleNFT.aliases[tenantID]!] as &Admin
        }

        pub fun depositMinter(NFTMinter: @NFTMinter) {
            self.minters[NFTMinter.tenantID] <-! NFTMinter
        }

         pub fun borrowMinter(tenantID: String): &NFTMinter {
            return &self.minters[SimpleNFT.aliases[tenantID]!] as &NFTMinter
        }

        pub fun borrowCollection(tenantID: String): &Collection {
            let original = SimpleNFT.aliases[tenantID]!
            if self.collections[original] == nil {
                self.setup(tenantID: original)
            }
            return &self.collections[original] as &Collection
        }

        pub fun borrowCollectionPublic(tenantID: String): &Collection{CollectionPublic} {
            return self.borrowCollection(tenantID: tenantID)
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
        pub fun getMetadata(id: UInt64): {String: String}
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

        pub fun getMetadata(id: UInt64): {String: String} {
            let ref = &self.ownedNFTs[id] as &NFT
            return ref.metadata
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
        self.aliases = {}

        self.PackageStoragePath = /storage/SimpleNFTPackage
        self.PackagePrivatePath = /private/SimpleNFTPackage
        self.PackagePublicPath = /public/SimpleNFTPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleNFT", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalURI: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalURI: "",
            _secondaryModules: nil
        )

         emit ContractInitialized()
    }
}
 