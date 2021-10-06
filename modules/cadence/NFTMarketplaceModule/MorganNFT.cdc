import HyperverseService from "../HyperverseService.cdc"
import IHyperverseComposable from "../IHyperverseComposable.cdc"
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"
import NonFungibleToken from "../Flow/NonFungibleToken.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract MorganNFT: IHyperverseModule, IHyperverseComposable, NonFungibleToken {

    // must be access(contract) because dictionaries can be
    // changed if they're pub
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    
    /* Requirements for the IHyperverseComposable */

    // the total number of tenants that have been created
    pub var totalTenants: UInt64

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenantMinter {
        pub let id: UInt64
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, ITenantMinter {
        pub let id: UInt64 

        pub let authNFT: Capability<&HyperverseService.AuthNFT>

        /* For MorganNFT Functionality */

        pub var totalSupply: UInt64

        pub let nftMinter: @NFTMinter

        pub fun nftMinterRef(): &NFTMinter {
            return &self.nftMinter as &NFTMinter
        }

        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }

        init(_authNFT: Capability<&HyperverseService.AuthNFT>) {
            /* For Composability */
            self.id = MorganNFT.totalTenants
            MorganNFT.totalTenants = MorganNFT.totalTenants + (1 as UInt64)
            self.authNFT = _authNFT

            /* For MorganNFT Functionality */
            self.totalSupply = 0
            self.nftMinter <- create NFTMinter()
        }

        destroy() {
            destroy self.nftMinter
        }
    }

    pub fun instance(authNFT: Capability<&HyperverseService.AuthNFT>): @Tenant {
        let clientTenant = authNFT.borrow()!.owner!.address
        if let count = self.clientTenants[clientTenant] {
            self.clientTenants[clientTenant] = self.clientTenants[clientTenant]! + (1 as UInt64)
        } else {
            self.clientTenants[clientTenant] = (1 as UInt64)
        }

        return <-create Tenant(_authNFT: authNFT)
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
        return <- create Collection(_tenantID: tenantID)
    }

    pub resource NFTMinter {
        pub fun mintNFT(tenant: &Tenant{ITenantMinter}): @NFT {
            return <- create NFT(_tenant: tenant)
        }
    }

    init() {
        /* For Secondary Export */
        self.clientTenants = {}
        self.totalTenants = 0

        self.totalSupply = 0

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "MorganNFT", 
            _authors: [HyperverseModule.Author(_address: 0x1, _external: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: 1632887513,
            _tenantStoragePath: /storage/NFTTenant,
            _external: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )

         emit ContractInitialized()
    }
}