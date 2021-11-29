import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import HNonFungibleToken from "../Hyperverse/HNonFungibleToken.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract SimpleNFT: IHyperverseComposable, HNonFungibleToken {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(tenant: Address)
    
    access(contract) var tenants: @{Address: IHyperverseComposable.Tenant}
    access(contract) fun getTenant(tenant: Address): &Tenant {
        let ref = &self.tenants[tenant] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    pub fun tenantExists(tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }

    pub resource Tenant: IHyperverseComposable.ITenant {
        pub(set) var totalSupply: UInt64
        
        pub var holder: Address

        init(_holder: Address) {
            self.totalSupply = 0
            self.holder = _holder
        }
    }

    // If we're making a new Tenant resource
    pub fun createTenant(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
    
        self.tenants[tenant] <-! create Tenant(_holder: tenant)

        let bundle: &Bundle = auth.bundles[self.getType().identifier]!.borrow()! as! &Bundle
        bundle.depositAdmin(Admin: <- create Admin(tenant))
        bundle.depositMinter(NFTMinter: <- create NFTMinter(tenant))

        emit TenantCreated(tenant: tenant)
    }

    /**************************************** BUNDLE ****************************************/

    pub let BundleStoragePath: StoragePath
    pub let BundlePrivatePath: PrivatePath
    pub let BundlePublicPath: PublicPath

    pub resource interface PublicBundle {
        pub fun borrowCollectionPublic(tenant: Address): &Collection{CollectionPublic}
        pub fun depositMinter(NFTMinter: @NFTMinter)
    }

    pub resource Bundle: PublicBundle {
        pub var collections: @{Address: HNonFungibleToken.Collection}
        pub var minters: @{Address: NFTMinter}
        pub var admins: @{Address: Admin}

        pub fun borrowCollection(tenant: Address): &Collection {
            if self.collections[tenant] == nil {
                self.collections[tenant] <-! create Collection(tenant)
            }
            let ref = &self.collections[tenant] as auth &HNonFungibleToken.Collection
            return ref as! &Collection
        }
        pub fun borrowCollectionPublic(tenant: Address): &Collection{CollectionPublic} {
            return self.borrowCollection(tenant: tenant)
        }

        pub fun depositMinter(NFTMinter: @NFTMinter) {
            self.minters[NFTMinter.tenant] <-! NFTMinter
        }
        pub fun borrowMinter(tenant: Address): &NFTMinter {
            return &self.minters[tenant] as &NFTMinter
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenant] <-! Admin
        }
        pub fun borrowAdmin(tenant: Address): &Admin {
            return &self.admins[tenant] as &Admin
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

    pub fun getBundle(): @Bundle {
        return <- create Bundle()
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
            let state = SimpleNFT.getTenant(tenant: tenant)
          
            self.id = self.uuid
            self.tenant = tenant
            self.metadata = _metadata

            state.totalSupply = state.totalSupply + 1
        }
    }

    pub resource interface CollectionPublic {
        pub let tenant: Address
        pub fun deposit(token: @HNonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun getMetadata(id: UInt64): {String: String}
    }

    pub resource Collection: CollectionPublic, HNonFungibleToken.Provider, HNonFungibleToken.Receiver, HNonFungibleToken.CollectionPublic {
        pub let tenant: Address
        pub var ownedNFTs: @{UInt64: HNonFungibleToken.NFT}

        pub fun deposit(token: @HNonFungibleToken.NFT) {
            let token <- token as! @NFT
            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(tenant: self.tenant, id: id, to: self.owner?.address)
            destroy oldToken
        }

        pub fun withdraw(withdrawID: UInt64): @HNonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(tenant: self.tenant, id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &HNonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &HNonFungibleToken.NFT
        }

        pub fun getMetadata(id: UInt64): {String: String} {
            let ref = &self.ownedNFTs[id] as auth &HNonFungibleToken.NFT
            let wholeNFT = ref as! &NFT
            return wholeNFT.metadata
        }

        destroy() {
            destroy self.ownedNFTs
        }

        init (_ tenant: Address) {
            self.tenant = tenant
            self.ownedNFTs <- {}
        }
    }

    pub resource NFTMinter {
        pub let tenant: Address
        pub fun mintNFT(metadata: {String: String}): @NFT {
            return <- create NFT(self.tenant, _metadata: metadata)
        }
        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }

    pub resource Admin {
        pub let tenant: Address
        pub fun createNFTMinter(): @NFTMinter {
            return <- create NFTMinter(self.tenant)
        }
        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }

    init() {
        self.tenants <- {}

        self.BundleStoragePath = /storage/SimpleNFTBundle
        self.BundlePrivatePath = /private/SimpleNFTBundle
        self.BundlePublicPath = /public/SimpleNFTBundle

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
 