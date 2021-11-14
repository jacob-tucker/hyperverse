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

@customElement('nft-harness')
export default class NFTHarness extends LitElement {
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
      
        <action-card title="SimpleNFT - Instance" description="Create your own Tenant" action="SimpleNFTInstance"
          method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Get Client Tenants" description="SimpleNFT TenantID for this account"
          action="SimpleNFTGetClientTenants" method="get" fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Give Minter" description="Give a SimpleNFT Minter to the recipient account"
          action="SimpleNFTGiveMinter" method="post" fields="tenantOwner recipient">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Mint NFT" description="Mint an NFT to the recipient account" action="SimpleNFTMintNFT"
          method="post" fields="tenantOwner signer recipient name">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="NFTMinter">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="name" label="Name of NFT" placeholder="BoredApe1">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Transfer NFT" description="Transfer an NFT" action="SimpleNFTTransferNFT"
          method="post" fields="tenantOwner signer recipient withdrawID">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="withdrawID" label="ID of the NFT" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Get NFT IDs" description="Get an account's NFT IDs" action="SimpleNFTGetNFTIDs"
          method="get" fields="account tenantOwner">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
