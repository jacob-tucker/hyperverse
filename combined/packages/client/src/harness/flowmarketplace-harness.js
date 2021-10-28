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

@customElement('flowmarketplace-harness')
export default class FlowMarketplaceHarness extends LitElement {
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
    
        <action-card title="FlowMarketplace - Instance"
            description="Instance. **You need a FlowMarketplace.Package to do this. **" action="FlowMarketplaceInstance"
            method="post" fields="signer SimpleNFTID">
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="SimpleNFTID" label="OPTIONAL Tenant ID for SimpleNFT" placeholder="46">
            </text-widget>
        </action-card>
    
        <action-card title="FlowMarketplace - Owns Tenant" description="Owns the FlowMarketplace Tenant"
            action="FlowMarketplaceOwnsTenant" method="get" fields="tenantOwner">
            <account-widget field="tenantOwner" label="Tenant Owner">
            </account-widget>
        </action-card>
    
        <action-card title="FlowMarketplace - Get Balance" description="Get Balance" action="FlowTokenGetBalance"
            method="get" fields="account">
            <account-widget field="account" label="Account">
            </account-widget>
        </action-card>
    
        <action-card title="FlowMarketplace - Mint NFT" description="Mint NFT" action="SimpleNFTMintNFT" method="post"
            fields="tenantID signer recipient name">
            <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.50">
            </text-widget>
            <account-widget field="signer" label="NFTMinter">
            </account-widget>
            <account-widget field="recipient" label="Recipient">
            </account-widget>
            <text-widget field="name" label="Name of NFT" placeholder="BoredApe1">
            </text-widget>
        </action-card>
    
        <action-card title="FlowMarketplace - List for Sale" description="List NFTs for Sale" action="FlowMarketplaceList"
            method="post" fields="signer tenantID price ids">
            <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.50">
            </text-widget>
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="price" label="Price" placeholder="20.0">
            </text-widget>
            <array-widget field="ids" label="All the NFTs to list" valueLabel="id" placeholder="0">
            </array-widget>
        </action-card>
    
        <action-card title="FlowMarketplace - Unlist Sale" description="Unlist an NFT for sale"
            action="FlowMarketplaceUnlist" method="post" fields="signer tenantID id">
            <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.50">
            </text-widget>
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="id" label="ID" placeholder="0">
            </text-widget>
        </action-card>
    
        <action-card title="FlowMarketplace - Purchase" description="Purchase an NFT from the FlowMarketplace."
            action="FlowMarketplacePurchase" method="post" fields="signer tenantID id marketplace">
            <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.50">
            </text-widget>
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="id" label="ID" placeholder="0">
            </text-widget>
            <account-widget field="marketplace" label="Marketplace Address">
            </account-widget>
        </action-card>
    
        <action-card title="FlowMarketplace - Get IDs"
            description="Get all the NFTs for sale in this FlowMarketplace.SaleCollection." action="FlowMarketplaceGetIDs"
            method="post" fields="account tenantID">
            <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.50">
            </text-widget>
            <account-widget field="account" label="Account">
            </account-widget>
        </action-card>
    
    </page-body>
    <page-panel id="resultPanel"></page-panel>
    `;

        return content;
    }
}
