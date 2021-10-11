import HyperverseService from "../HyperverseService.cdc"
import IHyperverseComposable from "../IHyperverseComposable.cdc"
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract NFTMarketplace: IHyperverseModule, IHyperverseComposable {

    // must be access(contract) because dictionaries can be
    // changed if they're pub
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    
    /* Requirements for the IHyperverseComposable */

    // the total number of tenants that have been created
    pub var totalTenants: UInt64

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenantPublic {
        access(contract) fun addParticipant(participant: Address, tribe: String?)
        access(contract) var participants: {Address: String?}
        access(contract) var tribes: {String: TribeData}
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, ITenantPublic {
        pub let id: UInt64 

        pub let authNFT: Capability<&HyperverseService.AuthNFT>

        // an array of tribe names
        pub var tribes: {String: TribeData}

        pub fun addTribe(tribeName: String) {
            self.tribes[tribeName] = TribeData()
        }

        // maps an address (of a user) to the tribe they are a part of
        pub var participants: {Address: String?}

        pub fun addParticipant(participant: Address, tribe: String?) {
            self.participants[participant] = tribe
            self.tribes[tribe!]!.addMember(member: participant)
        }

        init(_authNFT: Capability<&HyperverseService.AuthNFT>) {
            /* For Composability */
            self.id = NFTMarketplace.totalTenants
            NFTMarketplace.totalTenants = NFTMarketplace.totalTenants + (1 as UInt64)
            self.authNFT = _authNFT

            self.tribes = {}
            self.participants = {}
        }

        destroy() {

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

    /* Functionality of the NFTMarketplace Module */
    pub event TribesContractInitialized()

    pub resource Identity {
        // the person's username
        pub var username: String

        // the address this identity belongs to
        pub let address: Address

        // the tribe this user is a part of
        pub var currentTribe: String?

        // changes the current tribe
        access(contract) fun changeCurrentTribe(newTribe: String?) {
            self.currentTribe = newTribe
        }

        init(_username: String, _address: Address) {
            self.username = _username
            self.address = _address
            self.currentTribe = nil
        }
    }

    // creates and returns a new identity. you have to pass in an address
    // and a username
    pub fun createIdentity(tenant: &Tenant{ITenantPublic}, username: String, participant: Address): @Identity {
        tenant.addParticipant(participant: participant, tribe: nil)
        return <- create Identity(_username: username, _address: participant)
    }

    pub struct TribeData {

        pub var members: {Address: Bool}

        pub fun addMember(member: Address) {
            self.members[member] = true
        }

        pub fun removeMember(member: Address) {
            self.members.remove(key: member)
        }

        init() {
            self.members = {}
        }
    }
    
    // given to a person in the tribe
    pub resource Tribe {
        pub let name: String

        pub let joinDate: UFix64

        init(_name: String) {
            self.name = _name 
            self.joinDate = getCurrentBlock().timestamp
        }
    }

    pub fun joinTribe(tenant: &Tenant{ITenantPublic}, identity: &Identity, tribe: String): @Tribe {
        pre {
            identity.address == identity.owner!.address: "Hacker!"
            tenant.participants.containsKey(identity.address): "Identity isn't registered for some reason"
            tenant.participants[identity.address] == nil: "Participant is already in a Tribe!"
            tenant.tribes.keys.contains(tribe): "Tribe does not exist!"
        }
        identity.changeCurrentTribe(newTribe: tribe)
        tenant.addParticipant(participant: identity.address, tribe: tribe)

        return <- create Tribe(_name: tribe)
    }

     pub fun leaveTribe(tenant: &Tenant{ITenantPublic}, identity: &Identity, tribeResource: @Tribe) {
        pre {
            identity.address == identity.owner!.address: "Hacker!"
            tenant.participants.containsKey(identity.address): "Identity isn't registered for some reason"
            tenant.participants[identity.address] != nil: "Participant is not already in a Tribe!"
        }
        identity.changeCurrentTribe(newTribe: nil)
        tenant.addParticipant(participant: identity.address, tribe: nil)
        destroy tribeResource
    }

    init() {
        /* For Secondary Export */
        self.clientTenants = {}
        self.totalTenants = 0

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Tribes", 
            _authors: [HyperverseModule.Author(_address: 0x1, _externalLink: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: 1632887513,
            _tenantStoragePath: /storage/Tribes,
            _externalLink: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )

        emit TribesContractInitialized()
    }
}