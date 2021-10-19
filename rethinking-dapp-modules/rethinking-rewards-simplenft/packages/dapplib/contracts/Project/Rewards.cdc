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
    access(contract) var tenants: @{UInt64: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: UInt64): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    // All of the getters and setters.
    // ** Setters MUST be access(contract) or access(account) **
    pub resource interface IState {
       pub let id: UInt64
       pub let SNFTTenantID: UInt64
    }
    
    // Implement dependency's IState
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let id: UInt64
        pub var holder: Address

        pub let SNFTTenantID: UInt64

        init(_tenantID: UInt64, _holder: Address, _SNFTTenantID: UInt64) {
            self.id = _tenantID
            self.holder = _holder
            self.SNFTTenantID = _SNFTTenantID
        }
    }
    // Returns a Tenant.
    pub fun instance(package: &Package) {
        let tenantID = Rewards.totalTenants
        Rewards.totalTenants = Rewards.totalTenants + (1 as UInt64)

        // This will give the caller's `package` a SimpleNFT.Admin and a SimpleNFT.NFTMinter
        // inside their SimpleNFT.Package at the `SNFTTenantID`. 
        let SNFTTenantID = SimpleNFT.instance(package: package.SimpleNFTPackage.borrow()!)
        Rewards.tenants[tenantID] <-! create Tenant(_tenantID: tenantID, _holder: package.owner!.address, _SNFTTenantID: SNFTTenantID)
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

       access(contract) fun getMinterInContract(tenantID: UInt64): &SimpleNFT.NFTMinter
    }
    // Need to include the dependency's package here
    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
    
        pub fun setup(tenantID: UInt64) {
            // No additional setup required here...

            // so call the next setup in the dependency tree (could be multiple).
            self.SimpleNFTPackage.borrow()!.setup(tenantID: Rewards.getTenant(id: tenantID).SNFTTenantID)
        }

        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }

        // Won't work if you aren't a NFTMinter, but that's fine.
        access(contract) fun getMinterInContract(tenantID: UInt64): &SimpleNFT.NFTMinter {
            return self.SimpleNFTPackage.borrow()!.borrowMinter(tenantID: tenantID) as &SimpleNFT.NFTMinter
        }

        init(_SimpleNFTPackage: Capability<&SimpleNFT.Package>) {
            self.SimpleNFTPackage = _SimpleNFTPackage
        }
    }

    // Yes, it's a requirement that you have a SimpleNFT.Package before you do this.  
    // That will inevitably be done manually.
    // In the next contract, it will just take in a Capability<&Rewards.Package>, which will
    // theoretically already have a Capability<&SimpleNFT.Package> inside of it,
    pub fun getPackage(SimpleNFTPackage: Capability<&SimpleNFT.Package>): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package! Or you don't have one yet."
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event RewardsInitialized()

    // For this module
    pub fun giveReward(tenantID: UInt64, minterPackage: &Package{PackagePublic}, recipientPackage: &Package{PackagePublic}) {
        let SNFTTenantID = self.getTenant(id: tenantID).id
        let nftCollection = recipientPackage.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: SNFTTenantID)
        let ids = nftCollection.getIDs()
        if ids.length > 2 {
            let nftMinter = minterPackage.getMinterInContract(tenantID: SNFTTenantID)
            nftCollection.deposit(token: <- nftMinter.mintNFT(name: "Super Legendary Reward"))
        } else {
            panic("Sorry! You are not cool enough. Need more NFTs!!!")
        }
    }
    
    init() {
        self.totalTenants = 0
        self.tenants <- {}

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