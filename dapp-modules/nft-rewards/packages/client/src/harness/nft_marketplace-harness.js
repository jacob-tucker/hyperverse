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
      
        <action-card title="SimpleNFT - Instance" description="Instance" action="SimpleNFTInstance" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Has Tenant" description="Has SimpleNFT Tenant" action="SimpleNFTHasTenant"
          method="get" fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Get NFT Collection" description="Get NFT Collection"
          action="SimpleNFTGetNFTCollection" method="post" fields="signer tenantID">
          <account-widget field="signer" label="Signer">
          </account-widget>
          <text-widget field="tenantID" label="Tenant ID" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Give Minter" description="Give Minter" action="SimpleNFTGiveMinter" method="post"
          fields="signer recipient">
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Mint NFT" description="Mint NFT" action="SimpleNFTMintNFT" method="post"
          fields="signer recipient tenant name">
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <account-widget field="tenant" label="SimpleNFT Tenant Account">
          </account-widget>
          <text-widget field="name" label="Name of NFT" placeholder="BoredApe">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Transfer NFT" description="Transfer NFT" action="SimpleNFTTransferNFT" method="post"
          fields="signer recipient withdrawID">
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="withdrawID" label="ID of the NFT" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Get NFT IDs" description="Get NFT IDs" action="SimpleNFTGetNFTIDs" method="get"
          fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Instance" description="Instance" action="RewardsInstance" method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Has Tenant" description="Has Rewards Tenant" action="RewardsHasTenant" method="get"
          fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
