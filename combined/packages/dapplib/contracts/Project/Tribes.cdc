import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"

pub contract Tribes: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub var totalTenants: UInt64

    // tenantID -> @Tenant{IState}
    access(contract) var tenants: @{UInt64: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: UInt64): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    pub resource interface IState {
        pub let id: UInt64
        pub var holder: Address
        access(contract) var participants: {Address: Bool}
        access(contract) var tribes: {String: TribeData}

        access(contract) fun addNewTribe(newTribeName: String)
        access(contract) fun addMember(tribe: String, member: Address)
        access(contract) fun removeMember(currentTribe: String, member: Address)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let id: UInt64 
        pub var holder: Address

        pub var tribes: {String: TribeData}
        pub var participants: {Address: Bool}

        pub fun addNewTribe(newTribeName: String) {
            self.tribes[newTribeName] = TribeData()
        }

        pub fun addMember(tribe: String, member: Address) {
            pre {
                self.participants[member] == nil || !self.participants[member]!:
                    "Member already belongs to a Tribe!"
            }
            self.tribes[tribe]!.addMember(member: member)
            self.participants[member] = true
        }

        pub fun removeMember(currentTribe: String, member: Address) {
            pre {
                self.participants[member]!:
                    "Member does not belong to a Tribe!"
            }
            self.tribes[currentTribe]!.removeMember(member: member)
            self.participants[member] = false
        }

        // pub fun addTribe(tribeName: String) {
        //     self.tribes[tribeName] = TribeData()
        // }

        init(_tenantID: UInt64, _holder: Address) {
            self.id = _tenantID
            self.holder = _holder
            self.tribes = {"Archers": TribeData(), "Soldiers": TribeData(), "Warriors": TribeData()}
            self.participants = {}
        }
    }

    pub fun instance(package: &Package): UInt64 {
        let tenantID = Tribes.totalTenants
        Tribes.totalTenants = Tribes.totalTenants + (1 as UInt64)
        Tribes.tenants[tenantID] <-! create Tenant(_tenantID: tenantID, _holder: package.owner!.address)

        package.depositAdmin(Admin: <- create Admin(tenantID))

        return tenantID
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
    // Any things that should be linked to the public
    pub resource interface PackagePublic {
        pub fun borrowIdentityPublic(tenantID: UInt64): &Identity{IdentityPublic}
    }
    // A Package is so that you can sort all the resources you WILL or MAY recieve 
    // as a part of you interacting with this contract by tenantID.
    //
    // This also removes the need to have a tenantID in every single resource.
    pub resource Package: PackagePublic {
        pub var identities: @{UInt64: Identity}
        pub var admins: @{UInt64: Admin}

        pub fun setup(tenantID: UInt64) {
            self.identities[tenantID] <-! create Identity(tenantID, _address: self.owner!.address)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenantID] <-! Admin
        }

        pub fun borrowAdmin(tenantID: UInt64): &Admin {
            pre {
                self.admins[tenantID] != nil:
                    "This Package does not have an Admin at this tenantID"
            }
            return &self.admins[tenantID] as &Admin
        }

        pub fun borrowIdentity(tenantID: UInt64): &Identity {
            return &self.identities[tenantID] as &Identity
        }

        pub fun borrowIdentityPublic(tenantID: UInt64): &Identity{IdentityPublic} {
            return &self.identities[tenantID] as &Identity{IdentityPublic}
        }

        init() {
            self.identities <- {}
            self.admins <- {}
        }

        destroy() {
            destroy self.identities
            destroy self.admins
        }
    }

    pub fun getPackage(): @Package {
        return <- create Package()
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event TribesContractInitialized()

    pub resource Admin {
        pub let tenantID: UInt64
        pub fun addNewTribe(newTribeName: String) {
            Tribes.getTenant(id: self.tenantID).addNewTribe(newTribeName: newTribeName)
        }

        init(_ tenantID: UInt64) {
            self.tenantID = tenantID
        }
    }

    pub fun joinTribe(identity: &Identity, tribe: String) {
        pre {
            Tribes.getTenant(id: identity.tenantID).tribes.keys.contains(tribe):
                "This Tribe does not exist!"
        }
        // Add member will check to see if the person already belongs to a Tribe.
        Tribes.getTenant(id: identity.tenantID).addMember(tribe: tribe, member: identity.address)
        identity.addTribe(newTribe: <- create Tribe(_name: tribe))
    }
    
    pub fun leaveTribe(identity: &Identity) {
        // Remove member will check to see if the person already belongs to a Tribe.
        Tribes.getTenant(id: identity.tenantID).removeMember(currentTribe: identity.currentTribeName!, member: identity.address)
        identity.removeTribe()
    }


    pub resource interface IdentityPublic {
        pub let address: Address
        pub var currentTribeName: String?
    }

    pub resource Identity: IdentityPublic {
        pub let tenantID: UInt64

        // the address this identity belongs to
        pub let address: Address

        // the tribe this user is a part of
        pub var currentTribe: @Tribe?

        pub var currentTribeName: String?

        // changes the current tribe
        access(contract) fun addTribe(newTribe: @Tribe) {
            self.currentTribeName = newTribe.name

            log(newTribe.name)
            log(self.currentTribeName)

            let oldTribe <- self.currentTribe <- newTribe
            destroy oldTribe
        }

        access(contract) fun removeTribe() {
            self.currentTribeName = nil

            let oldTribe <- self.currentTribe <- nil
            destroy oldTribe
        }

        init(_ tenantID: UInt64, _address: Address) {
            self.tenantID = tenantID
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
        self.totalTenants = 0
        self.tenants <- {}

        // Set our named paths
        self.PackageStoragePath = /storage/TribesPackage
        self.PackagePrivatePath = /private/TribesPackage
        self.PackagePublicPath = /public/TribesPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Tribes", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalLink: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalUri: "https://externalLink.net/1234567890",
            _secondaryModules: nil
        )

        emit TribesContractInitialized()
    }
}