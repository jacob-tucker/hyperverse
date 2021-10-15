import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import NonFungibleToken from "../Flow/NonFungibleToken.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract MorganNFT: IHyperverseModule, IHyperverseComposable, NonFungibleToken {

    // must be access(contract) because dictionaries can be
    // changed if they're pub
    access(contract) let metadata: HyperverseModule.ModuleMetadata

    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }
    
    /* Requirements for the IHyperverseComposable */

    pub var totalTenants: UInt64

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenantState {
        pub let id: UInt64
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }
    
    pub resource Tenant: IHyperverseComposable.ITenantID, ITenantState {
        pub let id: UInt64

         /* For MorganNFT Functionality */

        pub var totalSupply: UInt64

        pub fun createNewMinter(): @NFTMinter {
            return <- create NFTMinter()
        }

        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }

        init(_tenantID: UInt64) {
            /* For Composability */
            self.id = _tenantID

            /* For MorganNFT Functionality */
            self.totalSupply = 0
        }
    }

    pub fun instance(): @Tenant {
        let tenantID = MorganNFT.totalTenants

           MorganNFT.totalTenants = MorganNFT.totalTenants + (1 as UInt64)

        return <-create Tenant(_tenantID: tenantID)
    }

    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    pub let TenantCollectionStoragePath: StoragePath
    pub let TenantCollectionPublicPath: PublicPath

    pub resource TenantCollection: IHyperverseComposable.ITenantCollectionPublic {
        // dictionary of Tenant conforming tenants
        pub var ownedTenants: @{UInt64: IHyperverseComposable.Tenant}

        // deposit takes a Tenant and adds it to the ownedTenants dictionary
        // and adds the tenantID to the key
        pub fun deposit(tenant: @IHyperverseComposable.Tenant) {
            let tenant <- tenant as! @Tenant

            let id: UInt64 = tenant.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedTenants[id] <- tenant

            destroy oldToken
        }

        pub fun getTenantIDs(): [UInt64] {
            return self.ownedTenants.keys
        }

        pub fun borrowTenant(tenantID: UInt64): &IHyperverseComposable.Tenant {
            return &self.ownedTenants[tenantID] as &IHyperverseComposable.Tenant
        }

        pub fun borrowTenantState(tenantID: UInt64): &Tenant{ITenantState} {
            let ref = &self.ownedTenants[tenantID] as auth &IHyperverseComposable.Tenant
            let ref2 = ref as! &Tenant
            return ref2 as &Tenant{ITenantState}
        }

        init () {
            self.ownedTenants <- {}
        }

        destroy() {
            destroy self.ownedTenants
        }
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
    
        init(_tenant: &Tenant{ITenantState}) {
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
            tenantID < MorganNFT.totalTenants: "This Tenant does not exist!"
        }
        return <- create Collection(_tenantID: tenantID)
    }

    pub resource NFTMinter {
        pub fun mintNFT(tenant: &Tenant{ITenantState}, recipientCollection: &Collection{NonFungibleToken.CollectionPublic}) {
            recipientCollection.deposit(token: <- create NFT(_tenant: tenant))
        }
    }

    init() {
        /* For Secondary Export */
        self.totalTenants = 0
        self.clientTenants = {}

        self.totalSupply = 0
        // Set our named paths
        self.TenantCollectionStoragePath = /storage/TenantMorganNFTCollection
        self.TenantCollectionPublicPath = /public/TenantMorganNFTCollection
        self.CollectionStoragePath = /storage/MorganNFTCollection
        self.CollectionPublicPath = /public/MorganNFTCollection

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