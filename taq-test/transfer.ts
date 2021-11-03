import { token_transfer } from './token-transfer'

const RPC_URL = 'https://granadanet.smartpy.io/'
const CONTRACT = 'KT1Tb7kjQQH4TrqzccQ5PUHejag9GTE13vpT' //address of the published contract
const SENDER = 'tz1gYZYJQAGexEjir8hVXpRYYH9DeoyG9mLc' //public address of the sender (find it in acc.json)
const RECEIVER = 'tz1W5DS644McHaDitfjfiMPviU7FbnRA4SmS' // recipient's public address (take it from the Tezos wallet you had created)
const AMOUNT = 3 //number of tokens to be sent, you can put another value here
new token_transfer(RPC_URL).transfer(CONTRACT, SENDER, RECEIVER, AMOUNT)