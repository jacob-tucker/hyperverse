import DappLib from "@decentology/dappstarter-dapplib";
import DOM from "../components/dom";
import "../components/action-card.js";
import "../components/action-button.js";
import "../components/text-widget.js";
import "../components/number-widget.js";
import "../components/account-widget.js";
import "../components/upload-widget.js";
import { unsafeHTML } from "lit-html/directives/unsafe-html";
import { LitElement, html, customElement, property } from "lit-element";

@customElement("harness-page")
export default class HarnessPage extends LitElement {
  @property()
  get;
  @property()
  post;
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
    let page = localStorage.getItem('dappstarter-page');
    if (page.includes('-')) {
      setTimeout(() => {
        this.setPageLoader(page);
      }, 0);
    }
  }

  getPages() {
    return[
      {
        name: "core-helloworld",
        title: "Hello World",
        description: "Hello, World!",
        category: "Hyperverse",
        route: "/playground/harness/core-helloworld",
      },
      {
        name: "core-nft",
        title: "SimpleNFT",
        description: "Mint, own, and trade Simple NFTs with a name field.",
        category: "Hyperverse",
        route: "/playground/harness/core-nft",
      },
      {
        name: "core-token",
        title: "SimpleToken",
        description: "Mint, own, and trade Simple Fungible Tokens.",
        category: "Hyperverse",
        route: "/playground/harness/core-token",
      },
      {
        name: "core-tribes",
        title: "Tribes",
        description: "Join tribes and become part of a group.",
        category: "Hyperverse",
        route: "/playground/harness/core-tribes",
      },
      {
        name: "core-simplenftmarketplace",
        title: "SimpleNFT Marketplace",
        description: "Buy/sell SimpleNFTs using FlowToken.",
        category: "Hyperverse",
        route: "/playground/harness/core-simplenftmarketplace",
      },
      {
        name: "core-rewards",
        title: "Rewards",
        description:
          "Mint, own, and trade Simple NFTs, and get a reward when you have __ SimpleNFTs.",
        category: "Hyperverse",
        route: "/playground/harness/core-rewards",
      },
      {
        name: "core-marketplace",
        title: "Marketplace",
        description: "Buy/sell SimpleNFTs using SimpleTokens.",
        category: "Hyperverse",
        route: "/playground/harness/core-marketplace",
      },
]; 
  }

  handleClick = e => {
    e.preventDefault();
    localStorage.setItem('dappstarter-page', e.target.dataset.link);
    this.setPageLoader(e.target.dataset.link);
  };

  setPageLoader(name) {
    let pageLoader = document.getElementById("page-loader");
    pageLoader.load(name, this.getPages());
    this.requestUpdate();
  }

  render() {
    let content = html`
      <div class="container m-auto">
        <div class="row fadeIn mt-3 p-2 block">
          <p class="mt-3">
            Welcome to the UI Harness! Each feature module you selected for your project 
            has a page that demonstrates all of the module's capabilities with a user interface. You can 
            try the various features, then copy code selectively to your Dapp page. To continue, 
            select a feature module.           
          </p>
        </div>
        <ul class="mt-3 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        ${this.getPages().map(page =>
              html`<li class="col-span-1 bg-white rounded-lg shadow h-64">
                      <div class="flex flex-col items-center p-6 h-full">
                        <div class="font-bold text-xl mb-2">${page.title}</div>
                        <p class="text-gray-700 text-base mb-3">${page.description}</p>
                        <div class="flex flex-row flex-grow">
                            <button
                              @click=${this.handleClick}
                              data-link=${page.name}
                              class="self-end text-white font-bold py-2 px-8 rounded bg-green-500 hover:bg-green-700"}"
                            >
                              View
                            </button>
                          </div>
                      </div>
                    </li>`)
        }
        </ul>
      </div>
    `; 
    return content;

  }
}



