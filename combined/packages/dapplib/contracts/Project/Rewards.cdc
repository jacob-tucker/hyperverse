import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"

pub contract Rewards: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    pub event TenantReused(id: String)
    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String] {
        return self.clientTenants[account]!
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }
    access(contract) var aliases: {String: String}
    pub fun addAlias(auth: &HyperverseAuth.Auth, original: Int, new: String) {
        let original = auth.owner!.address.toString()
                        .concat(".")
                        .concat(self.getType().identifier)
                        .concat(".")
                        .concat(original.toString())
        self.aliases[new] = original
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

    // Modules
    // String : the identifier of the contract
    // UInt64 : The incremented # (from 0) for that account. For example, you want your
    // 2nd Tenant from SimpleNFT, it'd be `1`.
    pub fun instance(auth: &HyperverseAuth.Auth, modules: {String: Int}): Int {
        var number: Int = 0
        if self.clientTenants[auth.owner!.address] != nil {
            number = self.clientTenants[auth.owner!.address]!.length
        } else {
            self.clientTenants[auth.owner!.address] = []
        }
        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)
                                .concat(".")
                                .concat(number.toString())
        
        /* Dependencies */
        if modules[SimpleNFT.getType().identifier] == nil {
            let tenantNumber = SimpleNFT.instance(auth: auth, modules: {})
            SimpleNFT.addAlias(auth: auth, original: tenantNumber, new: STenantID)
        } else {
            SimpleNFT.addAlias(auth: auth, original: modules[SimpleNFT.getType().identifier]!, new: STenantID)
        }

        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: auth.owner!.address)
        self.addAlias(auth: auth, original: number, new: STenantID)

        self.clientTenants[auth.owner!.address]!.append(STenantID)
        emit TenantCreated(id: STenantID)

        return number
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}

       access(contract) fun getMinterInContract(tenantID: String): &SimpleNFT.NFTMinter
    }

    // We don't need aliases in this Package
    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
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
        // Proof that we need alias at the contract level so we can do that here wait nvm LUL
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
        self.aliases = {}

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