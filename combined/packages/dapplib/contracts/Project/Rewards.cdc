import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract Rewards: IHyperverseModule, IHyperverseComposable {

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
       access(contract) var recipients: {Address: Bool}
       access(contract) fun addRecipient(recipient: Address)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: UInt64
        pub var holder: Address

        pub var recipients: {Address: Bool}
        pub fun addRecipient(recipient: Address) {
            self.recipients[recipient] = true
        }

        init(_tenantID: UInt64, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.recipients = {}
        }
    }
    
    pub fun instance(package: &Package, uid: &HyperverseModule.UniqueID): UInt64 {
        pre {
            uid.dependency || Rewards.clientTenants[package.owner!.address] == nil:
                "This user already owns a Tenant from this contract!"
        }
        var tenantID: UInt64 = uid.uuid
        let newTenant <- create Tenant(_tenantID: tenantID, _holder: package.owner!.address)
        Rewards.tenants[tenantID] <-! newTenant
        emit TenantCreated(id: tenantID)

        if !uid.dependency {
            Rewards.clientTenants[package.owner!.address] = tenantID
            uid.dependency = true
        }
        SimpleNFT.instance(package: package.SimpleNFTPackage.borrow()!, uid: uid)
        return tenantID
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}

       access(contract) fun getMinterInContract(tenantID: UInt64): &SimpleNFT.NFTMinter
    }

    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }
    
        pub fun setup(tenantID: UInt64) {
            // No additional setup required here...

            // so call the next setup in the dependency tree (could be multiple).
            self.SimpleNFTPackage.borrow()!.setup(tenantID: tenantID)
        }

        access(contract) fun getMinterInContract(tenantID: UInt64): &SimpleNFT.NFTMinter {
            return self.SimpleNFTPackage.borrow()!.borrowMinter(tenantID: tenantID) as &SimpleNFT.NFTMinter
        }

        init(_SimpleNFTPackage: Capability<&SimpleNFT.Package>) {
            self.SimpleNFTPackage = _SimpleNFTPackage
        }
    }

    // Yes, it's a requirement that you have a SimpleNFT.Package before you do this.  
    pub fun getPackage(SimpleNFTPackage: Capability<&SimpleNFT.Package>): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package! Or you don't have one yet."
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event RewardsInitialized()

    pub fun giveReward(tenantID: UInt64, minterPackage: &Package{PackagePublic}, recipientPackage: &Package{PackagePublic}) {
        let TenantState = self.getTenant(id: tenantID)
        if TenantState.recipients[recipientPackage.owner!.address] == true {
            panic("This recipient has already received a reward!")
        }
        let nftCollection = recipientPackage.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: tenantID)
        let ids = nftCollection.getIDs()
        if ids.length > 2 {
            let nftMinter = minterPackage.getMinterInContract(tenantID: tenantID)
            nftCollection.deposit(token: <- nftMinter.mintNFT(name: "Super Legendary Reward"))
            TenantState.addRecipient(recipient: recipientPackage.owner!.address)
        } else {
            panic("Sorry! You are not cool enough. Need more NFTs!!!")
        }
    }
    
    init() {
        self.clientTenants = {}
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
            _externalURI: "",
            _secondaryModules: [{(Address(0xe37a242dfff69bbc)): "SimpleNFT"}]
        )

        emit RewardsInitialized()
    }
}