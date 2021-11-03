import { TezosToolkit } from '@taquito/taquito';
import { importKey } from '@taquito/signer';

const provider = 'https://granadanet.smartpy.io/';

async function deploy() {
 const tezos = new TezosToolkit(provider);
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
        //smart contract code
        code: `{ parameter int ;
        storage int ;
        code { UNPAIR ; ADD ; NIL operation ; PAIR } }
            `,
        //storage state
        init: `0`,
        })

        //beginning to deploy
        console.log('Awaiting confirmation...')
        const contract = await op.contract()
        //deployment report: amount of used gas, storage state
        console.log('Gas Used', op.consumedGas)
        console.log('Storage', await contract.storage())
        //operation hash one can use to find the contract in the explorer
        console.log('Operation hash:', op.hash)
    } catch (ex) {
        console.error(ex)
    }
    

}
deploy();