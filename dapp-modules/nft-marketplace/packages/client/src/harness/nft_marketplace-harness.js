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

@customElement('nft-marketplace-harness')
export default class NFTMarketplaceHarness extends LitElement {
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
      
        <action-card title="Hyperverse Service - Register" description="Register" action="register" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="NFT Marketplace - Instance" description="Instance" action="nftMarketplaceInstance" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Hyperverse Service - Total Tenants" description="Total Tenants" action="totalTenants" method="get"
          fields="">
        </action-card>
      
        <action-card title="NFT Marketplace - Has NFT Marketplace Tenant" description="Has NFT Marketplace Tenant"
          action="nftMarketplaceHasNFTMarketplaceTenant" method="get" fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="NFT Marketplace - Get NFT Collection" description="Get NFT Collection"
          action="nftMarketplaceGetNFTCollection" method="post" fields="signer tenantID">
          <account-widget field="signer" label="Signer">
          </account-widget>
          <text-widget field="tenantID" label="Tenant ID" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="NFT Marketplace - Give Minter" description="Give Minter" action="nftMarketplaceGiveMinter"
          method="post" fields="signer recipient">
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="NFT Marketplace - Mint NFT" description="Mint NFT" action="nftMarketplaceMintNFT" method="post"
          fields="signer recipient morganNFTTenantAccount">
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <account-widget field="morganNFTTenantAccount" label="Morgan NFT Tenant Account">
          </account-widget>
        </action-card>
      
        <action-card title="NFT Marketplace - Get NFT IDs" description="Get NFT IDs" action="nftMarketplaceGetNFTIDs"
          method="get" fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
