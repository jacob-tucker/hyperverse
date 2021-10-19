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
      
        <action-card title="SimpleNFT - Get Package" description="Get Package" action="SimpleNFTGetPackage" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Setup"
          description="Setting up your SimpleNFT.Package. ** 'Recipient' MUST have a SimpleNFT.Package **"
          action="SimpleNFTSetup" method="post" fields="signer tenant">
          <account-widget field="tenant" label="Tenant">
          </account-widget>
          <account-widget field="signer" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Give Minter"
          description="Give Minter (Receiving a SimpleNFT.NFTMinter). ** 'Recipient' MUST have a SimpleNFT.Package **"
          action="SimpleNFTGiveMinter" method="post" fields="signer recipient">
          <account-widget field="signer" label="Tenant">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Mint NFT" description="Mint NFT" action="SimpleNFTMintNFT" method="post"
          fields="tenant signer recipient name">
          <account-widget field="tenant" label="Tenant">
          </account-widget>
          <account-widget field="signer" label="NFTMinter">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="name" label="Name of NFT" placeholder="BoredApe">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Transfer NFT" description="Transfer NFT" action="SimpleNFTTransferNFT" method="post"
          fields="tenant signer recipient withdrawID">
          <account-widget field="tenant" label="Tenant">
          </account-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="withdrawID" label="ID of the NFT" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Get NFT IDs" description="Get NFT IDs" action="SimpleNFTGetNFTIDs" method="get"
          fields="account tenant">
          <account-widget field="tenant" label="Tenant">
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
