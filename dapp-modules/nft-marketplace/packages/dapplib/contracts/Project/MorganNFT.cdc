import HyperverseService from "../Hyperverse/HyperverseService.cdc"
import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import NonFungibleToken from "../Flow/NonFungibleToken.cdc"
import ITenant from "../Hyperverse/ITenant.cdc"
import TenantCollection from "../Hyperverse/TenantCollection.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract MorganNFT: IHyperverseModule, IHyperverseComposable, NonFungibleToken, ITenant {

    // must be access(contract) because dictionaries can be
    // changed if they're pub
    access(contract) let metadata: HyperverseModule.ModuleMetadata

    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }
    
    /* Requirements for the IHyperverseComposable */

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenantMinter {
        pub let id: UInt64
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }
    
    pub resource Tenant: ITenant.ITenantID, ITenant.ITenantAuth, ITenantMinter {
        pub let id: UInt64

        pub let authNFT: Capability<&HyperverseService.AuthNFT>

        /* For MorganNFT TenantCollection */

        pub let tenantCollection: Capability<&TenantCollection.Collection>

        pub fun getTenantMinter(tenantID: UInt64): &Tenant{ITenantMinter} {
            let ref = self.tenantCollection.borrow()!.borrowTenant(tenantID: tenantID)
            let morganNFTRef = ref as! &Tenant
            return morganNFTRef as &Tenant{ITenantMinter}
        }

         /* For MorganNFT Functionality */

        pub var totalSupply: UInt64

        pub fun createNewMinter(): @NFTMinter {
            return <- create NFTMinter()
        }

        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }

        init(_tenantID: UInt64, _authNFT: Capability<&HyperverseService.AuthNFT>, _tenantCollection: Capability<&TenantCollection.Collection>) {
            /* For Composability */
            self.id = _tenantID
            self.authNFT = _authNFT

            /* For MorganNFT Functionality */
            self.totalSupply = 0
            self.tenantCollection = _tenantCollection
        }
    }

    pub fun instance(authNFT: Capability<&HyperverseService.AuthNFT>, tenantCollection: Capability<&TenantCollection.Collection>): UInt64 {
        let clientTenant = authNFT.borrow()!.owner!.address

        let tenantID = HyperverseService.totalTenants
        
        if let count = self.clientTenants[clientTenant] {
            self.clientTenants[clientTenant] = self.clientTenants[clientTenant]! + (1 as UInt64)
        } else {
            self.clientTenants[clientTenant] = (1 as UInt64)
        }

        tenantCollection.borrow()!.deposit(tenant: <-create Tenant(_tenantID: tenantID, _authNFT: authNFT, _tenantCollection: tenantCollection))

        return tenantID
    }

    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    /* Functionality of the MorganNFT Module */

    // Never used, just for the NFT standard
    pub var totalSupply: UInt64

    pub event ContractInitialized()

    pub event Withdraw(id: UInt64, from: Address?)

    pub event Deposit(id: UInt64, to: Address?)

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub let tenantID: UInt64
    
        init(_tenant: &Tenant{ITenantMinter}) {
            self.id = _tenant.totalSupply
            self.tenantID = _tenant.id

            _tenant.updateTotalSupply()

            // just to fit the standard
            MorganNFT.totalSupply = MorganNFT.totalSupply + (1 as UInt64)
        }
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub var tenantID: UInt64?

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @MorganNFT.NFT

            if self.tenantID == nil {
                self.tenantID = token.tenantID
            } else if self.tenantID != token.tenantID {
                panic("This token is from another Tenant and cannot be stored in this collection")
            }

            let id: UInt64 = token.id

            let oldToken <- self.ownedNFTs[id] <- token

            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }

            destroy oldToken
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }

        init (_tenantID: UInt64?) {
            self.ownedNFTs <- {}
            self.tenantID = _tenantID
        }
    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection(_tenantID: nil)
    }

    pub fun createEmptyCollectionSpecifyTenant(tenantID: UInt64): @Collection {
        pre {
            tenantID < HyperverseService.totalTenants: "This Tenant does not exist!"
        }
        return <- create Collection(_tenantID: tenantID)
    }

    pub resource NFTMinter {
        pub fun mintNFT(tenant: &Tenant{ITenantMinter}, recipientCollection: &Collection{NonFungibleToken.CollectionPublic}) {
            recipientCollection.deposit(token: <- create NFT(_tenant: tenant))
        }
    }

    init() {
        /* For Secondary Export */
        self.clientTenants = {}

        self.totalSupply = 0
         // Set our named paths
        self.CollectionStoragePath = /storage/morganNFTCollection
        self.CollectionPublicPath = /public/morganNFTCollection

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "MorganNFT", 
            _authors: [HyperverseModule.Author(_address: 0x1, _externalURI: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: 1632887513,
            _tenantStoragePath: /storage/MorganNFTTenant,
            _tenantPublicPath: /public/MorganNFTTenant,
            _externalURI: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )

         emit ContractInitialized()
    }
}