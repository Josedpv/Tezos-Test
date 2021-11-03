import { App } from './app'
//import Tx.ts
import { Tx } from './tx'
//change the RPC link from the mainnet to testnet. Don’t you fear smartpy in the link: it’s merely the server address.
const RPC_URL = 'https://granadanet.smartpy.io/'
const ADDRESS = 'tz1aRoaRhSpRYvFdyvgWLL6TGyRoGF51wDjM'
//call the function Tx, send it the testnet link, and ask to activate the account
new Tx(RPC_URL).activateAccount()

/*import { App } from './app'
//declaring the constant with the node’s address
const RPC_URL = 'https://granadanet.smartpy.io'
//declare the constant with the Everstake baker’s address
const ADDRESS = 'tz1aRoaRhSpRYvFdyvgWLL6TGyRoGF51wDjM'
//launching App, sending a link to the node, calling getBalance and sending it the address
new App(RPC_URL).getBalance(ADDRESS)*/