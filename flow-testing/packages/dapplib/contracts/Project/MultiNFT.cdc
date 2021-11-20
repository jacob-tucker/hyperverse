import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract MultiNFT: IHyperverseComposable {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    pub fun clientTenantID(account: Address): String {
        return account.toString().concat(".").concat(self.getType().identifier)
    }

    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun tenantExists(account: Address): Bool {
        return self.tenants[self.clientTenantID(account: account)] != nil
    }
    pub fun getTenant(account: Address): &Tenant {
        let ref = &self.tenants[self.clientTenantID(account: account)] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }

    pub resource Tenant: IHyperverseComposable.ITenant {
        pub let tenantID: String
        pub var totalSupply: {String: UInt64}
        access(contract) fun updateTotalSupply(type: String) {
            self.totalSupply[type] = self.totalSupply[type]! + 1
        }
        access(contract) fun addNewNFTType(type: String) {
            self.totalSupply[type] = 0
        }
        pub var holder: Address

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.totalSupply = {}
            self.holder = _holder
        }
    }
 
    // If we're making a new Tenant resource
    pub fun instance(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        var STenantID: String = self.clientTenantID(account: tenant)
    
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: tenant)

        let package = auth.packages[self.getType().identifier]!.borrow()! as! &Package
        package.depositAdmin(Admin: <- create Admin(tenant))
        package.depositMinter(NFTMinter: <- create NFTMinter(tenant))

        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
        pub fun borrowCollectionPublic(tenant: Address): &Collection{CollectionPublic}
        pub fun depositMinter(NFTMinter: @NFTMinter)
    }

    // All of the getAlias stuff only happens in this Package :)
    pub resource Package: PackagePublic {
        pub var collections: @{Address: Collection}
        pub var admins: @{Address: Admin}
        pub var minters: @{Address: NFTMinter}

        pub fun borrowCollection(tenant: Address): &Collection {
            if self.collections[tenant] == nil {
                self.collections[tenant] <-! create Collection(tenant)
            }
            return &self.collections[tenant] as &Collection
        }
        pub fun borrowCollectionPublic(tenant: Address): &Collection{CollectionPublic} {
            return self.borrowCollection(tenant: tenant)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenant] <-! Admin
        }

        pub fun borrowAdmin(tenant: Address): &Admin {
            return &self.admins[tenant] as &Admin
        }

        pub fun depositMinter(NFTMinter: @NFTMinter) {
            self.minters[NFTMinter.tenant] <-! NFTMinter
        }

         pub fun borrowMinter(tenant: Address): &NFTMinter {
            return &self.minters[tenant] as &NFTMinter
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
        pub let tenant: Address
        pub let type: String
        pub let id: UInt64
        pub var metadata: {String: String}
    
        init(_ tenant: Address, _type: String, _metadata: {String: String}) {
            let state = MultiNFT.getTenant(account: tenant)

            self.id = state.totalSupply[_type]!
            self.type = _type
            self.tenant = tenant
            self.metadata = _metadata

            state.updateTotalSupply(type: _type)
        }
    }

    pub resource interface CollectionPublic {
        pub let tenant: Address
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
        pub fun getMetadata(id: UInt64): {String: String}
    }

    pub resource Collection: CollectionPublic {
        pub let tenant: Address
        pub var ownedNFTs: @{UInt64: NFT}

        pub fun deposit(token: @NFT) {
            pre {
                self.tenant == token.tenant: "This token belongs to a different Tenant."
            }
            let id: UInt64 = token.uuid
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

        init (_ tenant: Address) {
            self.tenant = tenant
            self.ownedNFTs <- {}
        }
    }

    pub resource Admin {
        pub let tenant: Address
        pub fun createNFTMinter(): @NFTMinter {
            return <- create NFTMinter(self.tenant)
        }
        pub fun addNewNFTType(type: String) {
            MultiNFT.getTenant(account: self.tenant).addNewNFTType(type: type)
        }
        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }

    pub resource NFTMinter {
        pub let tenant: Address
        pub fun mintNFT(type: String, metadata: {String: String}): @NFT {
            return <- create NFT(self.tenant, _type: type, _metadata: metadata)
        }
        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }

    init() {
        self.tenants <- {}

        self.PackageStoragePath = /storage/MultiNFTPackage
        self.PackagePrivatePath = /private/MultiNFTPackage
        self.PackagePublicPath = /public/MultiNFTPackage

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "MultiNFT", 
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
 