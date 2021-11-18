import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract Tribes: IHyperverseComposable {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    pub fun clientTenantID(account: Address): String {
        return account.toString().concat(".").concat(self.getType().identifier)
    }
    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun getTenant(account: Address): &Tenant{IHyperverseComposable.ITenant, IState} {
        let ref = &self.tenants[self.clientTenantID(account: account)] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }

    pub resource interface IState {
        pub let tenantID: String
        access(contract) var participants: {Address: Bool}
        access(contract) var tribes: {String: TribeData}

        pub fun getAllTribes(): {String: TribeData}
        pub fun getTribeData(tribeName: String): TribeData
        access(contract) fun addNewTribe(newTribeName: String, ipfsHash: String, description: String)
        access(contract) fun addMember(tribe: String, member: Address)
        access(contract) fun removeMember(currentTribe: String, member: Address)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        pub var tribes: {String: TribeData}
        pub var participants: {Address: Bool}

        pub fun getAllTribes(): {String: TribeData} {
            return self.tribes
        }

        pub fun getTribeData(tribeName: String): TribeData {
            return self.tribes[tribeName]!
        }

        pub fun addNewTribe(newTribeName: String, ipfsHash: String, description: String) {
            self.tribes[newTribeName] = TribeData(_ipfsHash: ipfsHash, _description: description)
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

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.tribes = {}
            self.participants = {}
        }
    }

    pub fun instance(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        var STenantID: String = self.clientTenantID(account: tenant)
        
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: tenant)
        
        let package = auth.packages[self.getType().identifier]!.borrow()! as! &Package
        package.depositAdmin(Admin: <- create Admin(tenant))
        
        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
        pub fun borrowIdentityPublic(tenant: Address): &Identity{IdentityPublic}
    }
   
    pub resource Package: PackagePublic {
        pub var identities: @{Address: Identity}
        pub var admins: @{Address: Admin}

        pub fun borrowIdentity(tenant: Address): &Identity {
            if self.identities[tenant] == nil {
                self.identities[tenant] <-! create Identity(tenant, _address: self.owner!.address)
            }
            return &self.identities[tenant] as &Identity
        }
        pub fun borrowIdentityPublic(tenant: Address): &Identity{IdentityPublic} {
            return self.borrowIdentity(tenant: tenant)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenant] <-! Admin
        }
        pub fun borrowAdmin(tenant: Address): &Admin {
            return &self.admins[tenant] as &Admin
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
        pub let tenant: Address
        pub fun addNewTribe(newTribeName: String, ipfsHash: String, description: String) {
            Tribes.getTenant(account: self.tenant).addNewTribe(newTribeName: newTribeName, ipfsHash: ipfsHash, description: description)
        }

        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }

    pub fun joinTribe(identity: &Identity, tribe: String) {
        pre {
            Tribes.getTenant(account: identity.tenant).tribes.keys.contains(tribe):
                "This Tribe does not exist!"
        }
        Tribes.getTenant(account: identity.tenant).addMember(tribe: tribe, member: identity.address)
        identity.addTribe(newTribe: <- create Tribe(_name: tribe))
    }
    
    pub fun leaveTribe(identity: &Identity) {
        Tribes.getTenant(account: identity.tenant).removeMember(currentTribe: identity.currentTribeName!, member: identity.address)
        identity.removeTribe()
    }


    pub resource interface IdentityPublic {
        pub let address: Address
        pub var currentTribeName: String?
    }

    pub resource Identity: IdentityPublic {
        pub let tenant: Address
        pub let address: Address
        pub var currentTribe: @Tribe?
        pub var currentTribeName: String?

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

        init(_ tenant: Address, _address: Address) {
            self.tenant = tenant
            self.address = _address
            self.currentTribe <- nil
            self.currentTribeName = nil
        }

        destroy() {
            destroy self.currentTribe
        }
    }

    pub struct TribeData {

        pub let ipfsHash: String

        pub var description: String

        access(contract) var members: {Address: Bool}

        pub fun getMembers(): [Address] {
            return self.members.keys
        }

        access(contract) fun addMember(member: Address) {
            self.members[member] = true
        }

        access(contract) fun removeMember(member: Address) {
            self.members.remove(key: member)
        }

        init(_ipfsHash: String, _description: String) {
            self.ipfsHash = _ipfsHash
            self.members = {}
            self.description = _description
        }
    }
    
    pub resource Tribe {
        pub let name: String

        pub let joinDate: UFix64

        init(_name: String) {
            self.name = _name 
            self.joinDate = getCurrentBlock().timestamp
        }
    }

    init() {
        self.tenants <- {}

        self.PackageStoragePath = /storage/TribesPackage
        self.PackagePrivatePath = /private/TribesPackage
        self.PackagePublicPath = /public/TribesPackage

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "Tribes", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalUri: "",
                _secondaryModules: nil
            )
        )

        emit TribesContractInitialized()
    }
}