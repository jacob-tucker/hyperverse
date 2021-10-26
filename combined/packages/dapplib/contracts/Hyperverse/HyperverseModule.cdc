pub contract HyperverseModule {
    
    pub struct ModuleMetadata {
        pub var title: String
        
        pub var authors: [Author]

        // semver for versioning
        // 0.0.1
        pub var version: String

        // unix timestamp (ms)
        pub var publishedAt: UFix64

        // off-chain metadata
        // 
        // tags?
        // license?
        // License: https://choosealicense.com/licenses/apache-2.0/
        // Drop down of 3 different licenses? MIT, Apache, Berkeley
        // Open question, ties into the discussion about submission
        // process.
        //
        // Maybe this is external
        pub var externalURI: String

        // nil or the names of the .cdc files
        pub var secondaryModules: [{Address: String}]?

        init(
            _title: String, 
            _authors: [Author], 
            _version: String, 
            _publishedAt: UFix64,
            _externalURI: String,
            _secondaryModules: [{Address: String}]?,
        ) {
            self.title = _title
            self.authors = _authors
            self.version = _version
            self.publishedAt = _publishedAt
            self.externalURI = _externalURI
            self.secondaryModules = _secondaryModules
        }
    }

    pub struct Author {
        // required
        // Chain-native address
        pub var address: Address

        // required
        // All other chain addresses + any other metadata.
        // addresses on other chains
        pub var externalURI: String

        init(_address: Address, _externalURI: String) {
            self.address = _address
            self.externalURI = _externalURI
        }
    }

    pub resource UniqueID {
        pub(set) var dependency: Bool
        init() {
            self.dependency = false
        }
    }
    pub fun createUID(): @UniqueID {
        return <- create UniqueID()
    }

}