import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"

pub contract Rewards: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub var totalTenants: UInt64

    // All of the getters and setters.
    // ** Setters MUST be access(contract) or access(account) **
    pub resource interface IState {
       pub let id: UInt64
       pub fun giveReward(package: &Package{PackagePublic})
    }
    
    // Implement dependency's IState
    pub resource Tenant: IHyperverseComposable.ITenantID, IState, SimpleNFT.IState {
        // DUE TO IHyperverseComposable.ITenantID
        pub let id: UInt64 

        // DUE TO SimpleNFT.IState
        pub var totalSupply: UInt64
        pub fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + (1 as UInt64)
        }

        // BECAUSE WE USE A DEPENDENCY - Need this for every dependency
        pub let simpleNFT: @SimpleNFT.Tenant
        // Note that these capabilities actually refer to this Tenant resource
        pub var sC: Capability<&{SimpleNFT.IState}>?
        pub fun addSC(sC: Capability<&{SimpleNFT.IState}>) {
            self.sC = sC
        }

        // For this module
        pub fun mintNFT(package: &Package{PackagePublic}) {
            let nftMinter <- self.simpleNFT.createNewMinter(tenantC: self.sC!)
            package.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: self.simpleNFT.id).deposit(token: <- nftMinter.mintNFT(name: "Base Reward"))
            destroy nftMinter
        }
        pub fun giveReward(package: &Package{PackagePublic}) {
            let nftCollection = package.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: self.simpleNFT.id)
            let ids = nftCollection.getIDs()
            if ids.length > 2 {
                let nftMinter <- self.simpleNFT.createNewMinter(tenantC: self.sC!)
                nftCollection.deposit(token: <- nftMinter.mintNFT(name: "Super Legendary Reward"))
                destroy nftMinter
            } else {
                panic("Sorry! You are not cool enough. Need more NFTs!!!")
            }
        }

        init(_tenantID: UInt64) {
            self.id = _tenantID
            self.totalSupply = 0
            self.simpleNFT <- SimpleNFT.instance()
            self.sC = nil
        }

        destroy() {
            destroy self.simpleNFT
        }
    }
    // Returns a Tenant.
    pub fun instance(): @Tenant {
        let tenantID = Rewards.totalTenants
        Rewards.totalTenants = Rewards.totalTenants + (1 as UInt64)
        return <-create Tenant(_tenantID: tenantID)
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
    // Any things that should be linked to the public
    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}
    }
    // Need to include the dependency's package here
    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>

        pub fun setup(tenantID: UInt64) {
            self.SimpleNFTPackage.borrow()!.setup(tenantID: tenantID)
        }

        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }

        init(_SimpleNFTPackage: Capability<&SimpleNFT.Package>) {
            self.SimpleNFTPackage = _SimpleNFTPackage
        }
    }

    pub fun getPackage(SimpleNFTPackage: Capability<&SimpleNFT.Package>): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package!"
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event RewardsInitialized()
    
    init() {
        self.totalTenants = 0

        // Set our named paths
        self.PackageStoragePath = /storage/RewardsPackage
        self.PackagePrivatePath = /private/RewardsPackage
        self.PackagePublicPath = /public/RewardsPackage

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