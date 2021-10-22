import "../components/page-panel.js";
import "../components/page-body.js";
import "../components/action-card.js";
import "../components/account-widget.js";
import "../components/text-widget.js";
import "../components/number-widget.js";
import "../components/switch-widget.js";
import "../components/array-widget.js"
import "../components/dictionary-widget.js"

import DappLib from "@decentology/dappstarter-dapplib";
import { LitElement, html, customElement, property } from "lit-element";

@customElement('marketplace-harness')
export default class MarketplaceHarness extends LitElement {
    @property()
    title;
    @property()
    category;
    @property()
    description;

    createRenderRoot() {
        return this;
    }

    constructor(args) {
        super(args);
    }

    render() {
        let content = html`
    <page-body title="${this.title}" category="${this.category}" description="${this.description}">
    
        <action-card title="SimpleFT - Get Package" description="Get Package" action="SimpleFTGetPackage" method="post"
            fields="signer">
            <account-widget field="signer" label="Signer">
            </account-widget>
        </action-card>
    
        <action-card title="SimpleFT - Owns Tenant" description="Owns the SimpleFT Tenant" action="SimpleFTOwnsTenant"
            method="get" fields="account tenantID">
            <account-widget field="account" label="Account">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
        </action-card>
    
        <action-card title="SimpleFT - Mint FT" description="Mint FT" action="SimpleFTMintFT" method="post"
            fields="tenantID signer recipient amount">
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
            <account-widget field="signer" label="FTMinter">
            </account-widget>
            <account-widget field="recipient" label="Recipient">
            </account-widget>
            <text-widget field="amount" label="Amount of FT" placeholder="50">
            </text-widget>
        </action-card>
    
        <action-card title="SimpleFT - Get Balance" description="Get Balance" action="SimpleFTGetBalance" method="get"
            fields="tenantID account">
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
            <account-widget field="account" label="Account">
            </account-widget>
        </action-card>
    
        <action-card title="SimpleNFT - Get Package" description="Get Package" action="SimpleNFTGetPackage" method="post"
            fields="signer">
            <account-widget field="signer" label="Signer">
            </account-widget>
        </action-card>
    
        <action-card title="SimpleNFT - Owns Tenant" description="Owns the SimpleNFT Tenant" action="SimpleNFTOwnsTenant"
            method="get" fields="account tenantID">
            <account-widget field="account" label="Account">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
        </action-card>
    
        <action-card title="SimpleNFT - Mint NFT" description="Mint NFT" action="SimpleNFTMintNFT" method="post"
            fields="tenantID signer recipient name">
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
            <account-widget field="signer" label="NFTMinter">
            </account-widget>
            <account-widget field="recipient" label="Recipient">
            </account-widget>
            <text-widget field="name" label="Name of NFT" placeholder="BoredApe">
            </text-widget>
        </action-card>
    
        <action-card title="SimpleNFT - Get NFT IDs" description="Get NFT IDs" action="SimpleNFTGetNFTIDs" method="get"
            fields="account tenantID">
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
            <account-widget field="account" label="Account">
            </account-widget>
        </action-card>
    
        <action-card title="Marketplace - Get Package" description="Get Package" action="MarketplaceGetPackage"
            method="post" fields="signer">
            <account-widget field="signer" label="Signer">
            </account-widget>
        </action-card>
    
        <action-card title="Marketplace - Owns Tenant" description="Owns the Marketplace Tenant"
            action="MarketplaceOwnsTenant" method="get" fields="account tenantID">
            <account-widget field="account" label="Account">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
        </action-card>
    
        <action-card title="Marketplace - Instance"
            description="Instance. **You need a NFTMarketplace.Package to do this. **" action="MarketplaceInstance"
            method="post" fields="signer">
            <account-widget field="signer" label="Signer">
            </account-widget>
        </action-card>
    
        <action-card title="Marketplace - Setup" description="Instance. **You need a NFTMarketplace.Package to do this. **"
            action="MarketplaceSetup" method="post" fields="signer tenantID">
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
        </action-card>
    
        <action-card title="Marketplace - List for Sale" description="List NFTs for Sale" action="MarketplaceList"
            method="post" fields="signer tenantID price ids">
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
            <text-widget field="price" label="Price" placeholder="20.0">
            </text-widget>
            <array-widget field="ids" label="All the NFTs to list" valueLabel="id" placeholder="0">
            </array-widget>
        </action-card>
    
        <action-card title="Marketplace - Unlist Sale" description="Unlist an NFT for sale" action="MarketplaceUnlist"
            method="post" fields="signer tenantID id">
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
            <text-widget field="id" label="ID" placeholder="0">
            </text-widget>
        </action-card>
    
        <action-card title="Marketplace - Purchase" description="Purchase an NFT from the Marketplace."
            action="MarketplacePurchase" method="post" fields="signer tenantID id marketplace">
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
            <text-widget field="id" label="ID" placeholder="0">
            </text-widget>
            <account-widget field="marketplace" label="Marketplace Address">
            </account-widget>
        </action-card>
    
        <action-card title="Marketplace - Get IDs"
            description="Get all the NFTs for sale in this NFTMarketplace.SaleCollection." action="MarketplaceGetIDs"
            method="post" fields="account tenantID">
            <account-widget field="account" label="Account">
            </account-widget>
            <text-widget field="tenantID" label="Tenant" placeholder="0">
            </text-widget>
        </action-card>
    
    </page-body>
    <page-panel id="resultPanel"></page-panel>
    `;

        return content;
    }
}
