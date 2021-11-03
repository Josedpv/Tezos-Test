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
      code: JSON.parse(fs.readFileSync('./nft.json').toString()),
      // setting the storage state in Michelson. Replace both addresses with your account address on the testnet, and numbers with the number of tokens you want to issue.
      init:'(Pair (Pair { Elt 5 "tz1W5DS644McHaDitfjfiMPviU7FbnRA4SmS" } { Elt "" 0x68747470733a2f2f676973742e67697468756275736572636f6e74656e742e636f6d2f4a6f73656470762f38346339316465653235333831333430383938376163363061373135353738302f7261772f336464316439386465353436663133626438626638356134373331623966326235393534646632392f636f6e74726163745f6d6574612e6a736f6e }) { Elt (Pair "tz1W5DS644McHaDitfjfiMPviU7FbnRA4SmS" "tz1W5DS644McHaDitfjfiMPviU7FbnRA4SmS" 5) Unit } { Elt 0 (Pair 5 { Elt "" 0x68747470733a2f2f676973742e67697468756275736572636f6e74656e742e636f6d2f4a6f73656470762f34343866386538343939623166623361323433623863636138616532343963612f7261772f343765353066636662643066303363363331376366663062653933336163633961386531663131622f6e66745f6d6574612e6a736f6e }) })',
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

deploy();