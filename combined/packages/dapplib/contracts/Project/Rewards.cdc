import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"

pub contract Rewards: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String] {
        return self.clientTenants[account]!
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    pub resource interface IState {
       access(contract) var recipients: {Address: Bool}
       access(contract) fun addRecipient(recipient: Address)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        pub var recipients: {Address: Bool}
        pub fun addRecipient(recipient: Address) {
            self.recipients[recipient] = true
        }

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.recipients = {}
        }
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}

       access(contract) fun getMinterInContract(tenantID: String): &SimpleNFT.NFTMinter
    }

    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }

        pub fun instance(tenantID: UInt64) {
            var tenantIDConvention: String = self.owner!.address.toString().concat(".").concat(tenantID.toString())
            Rewards.tenants[tenantIDConvention] <-! create Tenant(_tenantID: tenantIDConvention, _holder: self.owner!.address)
            emit TenantCreated(id: tenantIDConvention)
            self.SimpleNFTPackage.borrow()!.instance(tenantID: tenantID)

            if Rewards.clientTenants[self.owner!.address] != nil {
                Rewards.clientTenants[self.owner!.address]!.append(tenantIDConvention)
            } else {
                Rewards.clientTenants[self.owner!.address] = [tenantIDConvention]
            }
        }
    
        pub fun setup(tenantID: String) {}

        access(contract) fun getMinterInContract(tenantID: String): &SimpleNFT.NFTMinter {
            return self.SimpleNFTPackage.borrow()!.borrowMinter(tenantID: tenantID) as &SimpleNFT.NFTMinter
        }

        init(_SimpleNFTPackage: Capability<&SimpleNFT.Package>) {
            self.SimpleNFTPackage = _SimpleNFTPackage
        }
    }

    pub fun getPackage(SimpleNFTPackage: Capability<&SimpleNFT.Package>): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package! Or you don't have one yet."
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event RewardsInitialized()

    pub fun giveReward(tenantID: String, minterPackage: &Package{PackagePublic}, recipientPackage: &Package{PackagePublic}) {
        let TenantState = self.getTenant(id: tenantID)
        if TenantState.recipients[recipientPackage.owner!.address] == true {
            panic("This recipient has already received a reward!")
        }
        let nftCollection = recipientPackage.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: tenantID)
        let ids = nftCollection.getIDs()
        if ids.length > 2 {
            let nftMinter = minterPackage.getMinterInContract(tenantID: tenantID)
            nftCollection.deposit(token: <- nftMinter.mintNFT(metadata: {"name": "Super Legendary Reward"}))
            TenantState.addRecipient(recipient: recipientPackage.owner!.address)
        } else {
            panic("Sorry! You are not cool enough. Need more NFTs!!!")
        }
    }
    
    init() {
        self.clientTenants = {}
        self.tenants <- {}

        self.PackageStoragePath = /storage/RewardsPackage
        self.PackagePrivatePath = /private/RewardsPackage
        self.PackagePublicPath = /public/RewardsPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Rewards", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalURI: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalURI: "",
            _secondaryModules: [{(Address(0x26a365de6d6237cd)): "SimpleNFT"}]
        )

        emit RewardsInitialized()
    }
}