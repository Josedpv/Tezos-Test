import { TezosToolkit } from '@taquito/taquito'
import { importKey } from '@taquito/signer'

const { Tezos } = require('@taquito/taquito')
const fs = require('fs')

const provider = 'https://granadanet.smartpy.io/'

async function deploy() {
  const tezos = new TezosToolkit(provider)
  await importKey(
    tezos,
    "znajnoko.glqdatbi@tezos.example.org",
    "WrA8zDlUnR",
    [
         "edge",
       "cigar",
       "sad",
       "gather",
       "evil",
       "code",
       "rib",
       "piece",
       "above",
       "poet",
       "curve",
       "tool",
       "mail",
       "dignity",
       "jar"
    ].join(' '),
    "630dc5deded449f5eb5f17c4edea3c4f3aa0e5dd"
  )

  try {
    const op = await tezos.contract.originate({
      // reading code from token.json
      code: JSON.parse(fs.readFileSync('./token.json').toString()),
      // setting the storage state in Michelson. Replace both addresses with your account address on the testnet, and numbers with the number of tokens you want to issue.
      init: '(Pair (Pair { Elt "tz1gYZYJQAGexEjir8hVXpRYYH9DeoyG9mLc" (Pair { Elt "tz1gYZYJQAGexEjir8hVXpRYYH9DeoyG9mLc" 1000 } 1000) } { Elt "" 0x68747470733a2f2f676973742e67697468756275736572636f6e74656e742e636f6d2f4a6f73656470762f65656339313738636662373065666464653636666635613636333162343330302f7261772f613535303566323935643963316161613063383861343639346431633739636163386433333633342f666131322d6d657461646174612e6a736f6e }) 1000)',
    })

    //deployment commences
    console.log('Awaiting confirmation...')
    const contract = await op.contract()
    //deployment report: amount of used gas, storage state
    console.log('Gas Used', op.consumedGas)
    console.log('Storage', await contract.storage())
    //operation hash one can use to find the contract in the blockchain explorer
    console.log('Operation hash:', op.hash)
  } catch (ex) {
    console.error(ex)
  }
}

deploy()