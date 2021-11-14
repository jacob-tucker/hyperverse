import HyperverseModule from "./HyperverseModule.cdc"

pub contract interface IHyperverseModule {
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata
}