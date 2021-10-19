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

@customElement('nft-rewards-harness')
export default class NFTRewardsHarness extends LitElement {
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
      
        <action-card title="SimpleNFT - Get Package" description="Get Package" action="SimpleNFTGetPackage" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Instance" description="Instance. **You need a SimpleNFT.Package to do this. **"
          action="SimpleNFTInstance" method="post" fields="signer">
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
      
        <action-card title="SimpleNFT - Setup"
          description="Setting up your SimpleNFT.Package. ** 'Recipient' MUST have a SimpleNFT.Package **"
          action="SimpleNFTSetup" method="post" fields="signer tenantID">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Give Minter"
          description="Give Minter (Receiving a SimpleNFT.NFTMinter). ** 'Recipient' MUST have a SimpleNFT.Package **"
          action="SimpleNFTGiveMinter" method="post" fields="tenantID signer recipient">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Tenant Owner">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
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
      
        <action-card title="SimpleNFT - Transfer NFT" description="Transfer NFT" action="SimpleNFTTransferNFT" method="post"
          fields="tenantID signer recipient withdrawID">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="withdrawID" label="ID of the NFT" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Get NFT IDs" description="Get NFT IDs" action="SimpleNFTGetNFTIDs" method="get"
          fields="account tenantID">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Get Package" description="Get Package. ** MUST Have SimpleNFT.Package **"
          action="RewardsGetPackage" method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Instance" description="Instance" action="RewardsInstance" method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Owns Tenant" description="Owns the Rewards Tenant" action="RewardsOwnsTenant"
          method="get" fields="tenantID account">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Setup"
          description="Setting up your Rewards.Package. ** 'Recipient' MUST have a Rewards.Package **" action="RewardsSetup"
          method="post" fields="signer tenantID">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Mint NFT" description="Mint NFT" action="RewardsMintNFT" method="post"
          fields="tenantID signer recipient">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Tenant Owner">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Give Reward" description="Give Reward" action="RewardsGiveReward" method="post"
          fields="tenantID signer minter">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="minter" label="Minter (Public)">
          </account-widget>
        </action-card>
      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
