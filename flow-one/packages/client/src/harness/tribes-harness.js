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

@customElement('tribes-harness')
export default class TribesHarness extends LitElement {
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
      
        <action-card title="Tribes - Instance" description="Create your own Tenant" action="TribesInstance" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Add a New Tribe" description="Add a New Tribe" action="TribesAddTribe" method="post"
          fields="tenantOwner newTribeName files description">
          <account-widget field="tenantOwner" label="Tenant Address">
          </account-widget>
          <text-widget field="newTribeName" label="Tribe Name" placeholder="Archers">
          </text-widget>
          <text-widget field="description" label="Description" placeholder="A group of Archers.">
          </text-widget>
          <upload-widget data-field="files" field="file" label="Tribe Image" placeholder="Select an image for your new Tribe"
            multiple="true">
          </upload-widget>
        </action-card>
      
        <action-card title="Tribes - Join a Tribe" description="Join a Tribe" action="TribesJoinTribe" method="post"
          fields="tenantOwner signer tribeName">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="Identity Owner">
          </account-widget>
          <text-widget field="tribeName" label="Tribe Name" placeholder="Archers">
          </text-widget>
        </action-card>
      
        <action-card title="Tribes - Leave Your Tribe" description="Leave your current Tribe" action="TribesLeaveTribe"
          method="post" fields="tenantOwner signer">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="Identity Owner">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Get Current Tribe" description="Get a User's Current Tribe"
          action="TribesGetCurrentTribe" method="get" fields="account tenantOwner">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Get All Tribes" description="Get all the Tribes" action="TribesGetAllTribes" method="get"
          fields="tenantOwner">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
        </action-card>
      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
