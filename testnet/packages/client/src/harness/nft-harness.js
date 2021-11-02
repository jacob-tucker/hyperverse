import "../components/page-panel.js";
import "../components/page-body.js";
import "../components/action-card.js";
import "../components/account-widget.js";
import "../components/text-widget.js";
import "../components/number-widget.js";
import "../components/switch-widget.js";
import "../components/array-widget.js"
import "../components/dictionary-widget.js"

import * as fcl from "@onflow/fcl"

import DappLib from "@decentology/dappstarter-dapplib";
import { LitElement, html, customElement, property } from "lit-element";

fcl.config()
  .put("challenge.handshake", "https://flow-wallet-testnet.blocto.app/authn")

@customElement('nft-harness')
export default class NFTHarness extends LitElement {
  @property()
  title;
  @property()
  category;
  @property()
  description;

  @property()
  user;

  createRenderRoot() {
    return this;
  }

  constructor(args) {
    super(args);
  }

  firstUpdated() {
    fcl.currentUser().subscribe(this.handleUser)
  }

  auth() {
    fcl.signUp()
    this.firstUpdated()
  }

  handleUser = (user) => {
    console.log(this.user)
    this.user = user
  };

  render() {
    let content = html`
      <page-body title="${this.title}" category="${this.category}" description="${this.description}">
      
        <button @click="${() => this.auth()}"
          class="text-white font-bold py-2 px-8 rounded bg-blue-500 hover:bg-blue-700">Login with FCL</button>
        <button @click="${() => fcl.unauthenticate()}"
          class="text-white font-bold py-2 px-8 rounded bg-red-500 hover:bg-red-700">Logout with FCL</button>
        <p class="text-white font-bold py-2 px-8 rounded bg-purple-500 hover:bg-purple-700">Current Address: ${this.user ?
        this.user.addr : null}</p>
      
        <action-card title="SimpleNFT - Instance" description="Instance. **You need a SimpleNFT.Package to do this. **"
          action="SimpleNFTInstance" method="post" fields="">
        </action-card>
      
        <action-card title="SimpleNFT - Owns Tenant" description="Owns the SimpleNFT Tenant" action="SimpleNFTOwnsTenant"
          method="get" fields="tenantOwner">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Give Minter"
          description="Give Minter (Receiving a SimpleNFT.NFTMinter). ** 'Recipient' MUST have a SimpleNFT.Package **"
          action="SimpleNFTGiveMinter" method="post" fields="tenantID recipient">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Mint NFT" description="Mint NFT" action="SimpleNFTMintNFT" method="post"
          fields="tenantID recipient name">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="name" label="Name of NFT" placeholder="BoredApe1">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Transfer NFT" description="Transfer NFT" action="SimpleNFTTransferNFT" method="post"
          fields="tenantID recipient withdrawID">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="withdrawID" label="ID of the NFT" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleNFT - Get NFT IDs" description="Get NFT IDs" action="SimpleNFTGetNFTIDs" method="get"
          fields="account tenantID">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
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
