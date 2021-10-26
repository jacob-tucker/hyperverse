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
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: UInt64
        pub var holder: Address
        pub var totalSupply: UInt64
        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }

        init(_tenantID: UInt64, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.totalSupply = 0
        }
    }

    pub fun instance(package: &Package, uid: &HyperverseModule.UniqueID): UInt64 {
        pre {
            uid.dependency || SimpleNFT.clientTenants[package.owner!.address] == nil:
                "This user already owns a Tenant from this contract!"
        }
        var tenantID: UInt64 = uid.uuid
        let newTenant <- create Tenant(_tenantID: tenantID, _holder: package.owner!.address)
        SimpleNFT.tenants[tenantID] <-! newTenant
        package.depositAdmin(Admin: <- create Admin(tenantID))
        package.depositMinter(NFTMinter: <- create NFTMinter(tenantID))
        emit TenantCreated(id: tenantID)

        if !uid.dependency {
            SimpleNFT.clientTenants[package.owner!.address] = tenantID
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
        pub fun borrowCollectionPublic(tenantID: UInt64): &Collection{CollectionPublic}
    }

    pub resource Package: PackagePublic {
        pub var collections: @{UInt64: Collection}
        pub var admins: @{UInt64: Admin}
        pub var minters: @{UInt64: NFTMinter}

        pub fun setup(tenantID: UInt64) {
            self.collections[tenantID] <-! create Collection(tenantID)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenantID] <-! Admin
        }

        pub fun borrowAdmin(tenantID: UInt64): &Admin {
            return &self.admins[tenantID] as &Admin
        }

        pub fun depositMinter(NFTMinter: @NFTMinter) {
            self.minters[NFTMinter.tenantID] <-! NFTMinter
        }

         pub fun borrowMinter(tenantID: UInt64): &NFTMinter {
            return &self.minters[tenantID] as &NFTMinter
        }

        pub fun borrowCollection(tenantID: UInt64): &Collection {
            return &self.collections[tenantID] as &Collection
        }

        pub fun borrowCollectionPublic(tenantID: UInt64): &Collection{CollectionPublic} {
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
        pub let tenantID: UInt64
        pub let id: UInt64
        pub let name: String
    
        init(_ tenantID: UInt64, _name: String) {
            let tenant = SimpleNFT.getTenant(id: tenantID)
          
            self.id = tenant.totalSupply
            self.tenantID = tenantID
            self.name = _name

            tenant.updateTotalSupply()
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

        init (_ tenantID: UInt64) {
            self.tenantID = tenantID
            self.ownedNFTs <- {}
        }
    }

    pub resource Admin {
        pub let tenantID: UInt64
        pub fun createNFTMinter(): @NFTMinter {
            return <- create NFTMinter(self.tenantID)
        }
        init(_ tenantID: UInt64) {
            self.tenantID = tenantID
        }
    }

    pub resource NFTMinter {
        pub let tenantID: UInt64
        pub fun mintNFT(name: String): @NFT {
            return <- create NFT(self.tenantID, _name: name)
        }
        init(_ tenantID: UInt64) {
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
 