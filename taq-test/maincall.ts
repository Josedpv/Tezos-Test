import { Call } from './call'

const RPC_URL = 'https://granadanet.smartpy.io/'
const CONTRACT = 'KT1LMpBM2RfUW5xjjkcYaqBp5gohB9T5xiRx' //published contract address
const ADD = 5 //number to be received by the main function. You can change it
new Call(RPC_URL).add(ADD, CONTRACT)