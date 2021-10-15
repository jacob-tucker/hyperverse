import IHyperverseComposable from "../IHyperverseComposable.cdc"
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"

pub contract Tribes: IHyperverseModule, IHyperverseComposable {

     /**************************************** METADATA ****************************************/

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    pub var totalTenants: UInt64

    // ** MUST be access(contract) **
    access(contract) var clientTenants: {Address: UInt64}
    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    /**************************************** TENANT ****************************************/

    pub resource interface IState {
        pub let id: UInt64
        access(contract) var participants: {Address: Bool}
        access(contract) var tribes: {String: TribeData}
        pub fun createIdentity(package: &Package)
        pub fun joinTribe(identity: &Identity, tribe: String)
        pub fun leaveTribe(identity: &Identity)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenantID, IState {
        pub let id: UInt64 

        /************ STATE ************/
        pub var tribes: {String: TribeData}
        pub var participants: {Address: Bool}

        /************ SETTERS ************/

        pub fun addTribe(tribeName: String) {
            self.tribes[tribeName] = TribeData()
        }

        /************ PUB FUNCTIONS ************/
        pub fun createIdentity(package: &Package) {
            pre {
                self.participants[package.owner!.address] == nil: "This user already has an Identity"
            }
            self.participants[package.owner!.address] = true
            package.depositIdentity(Identity: <- create Identity(_tenantID: self.id, _address: package.owner!.address))
        }

        pub fun joinTribe(identity: &Identity, tribe: String) {
            pre {
                self.participants[identity.address] != nil: "Identity isn't registered for some reason."
                self.participants[identity.address] == false: "Participant is already in a Tribe!"
                self.tribes.containsKey(tribe): "Tribe does not exist!"
            }
            identity.addTribe(newTribe: <- create Tribe(_name: tribe))
            self.tribes[tribe]!.addMember(member: identity.address)
        }

        pub fun leaveTribe(identity: &Identity) {
            pre {
                self.participants[identity.address] != nil: "Identity isn't registered for some reason."
                self.participants[identity.address] == true: "Participant isn't in a tribe."
                identity.currentTribe != nil: "This identity isn't part of a Tribe!"
            }
            self.tribes[identity.currentTribeName!]!.removeMember(member: identity.address)
            identity.removeTribe()
        }

        init(_tenantID: UInt64) {
            self.id = _tenantID
            self.tribes = {}
            self.participants = {}
        }
    }

    pub fun instance(): @Tenant {
        let tenantID = Tribes.totalTenants
        Tribes.totalTenants = Tribes.totalTenants + (1 as UInt64)
        return <- create Tenant(_tenantID: tenantID)
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePublicPath: PublicPath
    // Any things that should be linked to the public
    pub resource interface PackagePublic {
        
    }
    // A Package is so that you can sort all the resources you WILL or MAY recieve 
    // as a part of you interacting with this contract by tenantID.
    //
    // This also removes the need to have a tenantID in every single resource.
    pub resource Package: PackagePublic {
        pub let identities: @{UInt64: Identity}

        // Maybe have a map of tenantID: Capability<&Tenant{IState}> ??????

        pub fun depositIdentity(Identity: @Identity) {
            self.identities[Identity.tenantID] <-! Identity
        }

        pub fun borrowIdentity(tenantID: UInt64): &Identity {
            return &self.identities[tenantID] as &Identity
        }

        init() {
            self.identities <- {}
        }

        destroy() {
            destroy self.identities
        }
    }

    pub fun getPackage(): @Package {
        return <- create Package()
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event TribesContractInitialized()

    pub resource Identity {
        pub let tenantID: UInt64

        // the address this identity belongs to
        pub let address: Address

        // the tribe this user is a part of
        pub var currentTribe: @Tribe?

        pub var currentTribeName: String?

        // changes the current tribe
        access(contract) fun addTribe(newTribe: @Tribe) {
            self.currentTribeName = newTribe.name

            let oldTribe <- self.currentTribe <- newTribe
            destroy oldTribe
        }

        access(contract) fun removeTribe() {
            self.currentTribeName = nil

            let oldTribe <- self.currentTribe <- nil
            destroy oldTribe
        }

        init(_tenantID: UInt64, _address: Address) {
            self.tenantID = _tenantID
            self.address = _address
            self.currentTribe <- nil
            self.currentTribeName = nil
        }

        destroy() {
            destroy self.currentTribe
        }
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

    init() {
        /* For Secondary Export */
        self.clientTenants = {}
        self.totalTenants = 0

        // Set our named paths
        self.PackageStoragePath = /storage/TribesPackage
        self.PackagePublicPath = /public/TribesPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Tribes", 
            _authors: [HyperverseModule.Author(_address: 0x1, _externalLink: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _tenantStoragePath: /storage/TribesTenant,
            _tenantPublicPath: /public/TribesTenant,
            _externalUri: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )

        emit TribesContractInitialized()
    }
}