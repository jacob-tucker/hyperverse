import IHyperverseComposable from "../IHyperverseComposable.cdc"
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"

pub contract Rewards: IHyperverseModule, IHyperverseComposable {

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
       pub fun simpleNFTRef(): &SimpleNFT.Tenant{SimpleNFT.IState}
       pub fun giveReward(nftCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic})
    }
    
    pub resource Tenant: IHyperverseComposable.ITenantID, IState {
        pub let id: UInt64 

        pub let simpleNFT: @SimpleNFT.Tenant
        pub let simpleNFTMinter: @SimpleNFT.NFTMinter

        pub fun simpleNFTRef(): &SimpleNFT.Tenant{SimpleNFT.IState} {
            return &self.simpleNFT as &SimpleNFT.Tenant{SimpleNFT.IState}
        }

        pub fun mintNFT(collection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}) {
            collection.deposit(token: <- self.simpleNFTMinter.mintNFT(tenant: self.simpleNFTRef(), name: "Base Reward"))
        }

        pub fun giveReward( 
            nftCollection: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}
        ) {
            // Note: You don't need to check if the nftCollection.tenantID == self.simpleNFT.id,
            // that is done implicitly below.
            
            let ids = nftCollection.getIDs()
            if ids.length > 2 {
                let nftMinter <- self.simpleNFT.createNewMinter()
                nftCollection.deposit(token: <- nftMinter.mintNFT(tenant: self.simpleNFTRef(), name: "Super Legendary Reward"))
                destroy nftMinter
            } else {
                panic("Sorry! You are not cool enough. Need more NFTs!!!")
            }
        }

        init(_tenantID: UInt64) {
            self.id = _tenantID
            self.simpleNFT <- SimpleNFT.instance()
            self.simpleNFTMinter <- self.simpleNFT.createNewMinter()
        }

        destroy() {
            destroy self.simpleNFT
            destroy self.simpleNFTMinter
        }
    }
    // Returns a Tenant.
    pub fun instance(): @Tenant {
        let tenantID = Rewards.totalTenants
        Rewards.totalTenants = Rewards.totalTenants + (1 as UInt64)
        return <-create Tenant(_tenantID: tenantID)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event RewardsInitialized()
    
    init() {
        self.totalTenants = 0

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Rewards", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalURI: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _tenantStoragePath: /storage/RewardsTenant,
            _tenantPublicPath: /public/RewardsTenant,
            _externalURI: "https://externalLink.net/1234567890",
            _secondaryModules: [{self.account.address: "SimpleNFT"}]
        )

        emit RewardsInitialized()
    }
}