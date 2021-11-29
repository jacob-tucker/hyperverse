/**

## The Decentology Smart Module standard on Ethereum

## `IHyperverseModule` interface

In essense, this contract serves the equivalent of two purposes
in respect to Cadence:
1) Enforces the `metadata` variable (same as IHyperverseModule.cdc)
2) Defines what a ModuleMetadata is (sam as HyperverseModule.cdc)

*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

abstract contract IHyperverseModule {
    ModuleMetadata public metadata;

    constructor(
        bytes memory _title,
        Author memory _author,
        bytes memory _version, // 0.1.1
        uint64 _publishedAt,
        bytes memory _externalLink
    ) {
        metadata.title = _title;
        metadata.authors.push(_author);
        metadata.version = _version;
        metadata.publishedAt = _publishedAt;
        metadata.externalLink = _externalLink;
    }

    struct ModuleMetadata {
        bytes title; // <-- `pub var title: String` in Cadence
        Author[] authors;
        bytes version;
        uint64 publishedAt;
        bytes externalLink; // <-- can't be "external" in Solidity because it's a keyword
    }

    struct Author {
        address authorAddress; // <-- can't be "address" in Solidity because it's a keyword
        string externalLink;
    }
}
