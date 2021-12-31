# Tezos-Test

## Notice

This software is in beta. Testing of the Tezos-Test contracts
remains in progress and third-party audit results will be released 
in the coming weeks.

## Tezos-Test

Tezos-Test offers a set of packages to bring creation, management, test, communication and sales of NFTs in Pascal ligo.
-   A collection of test, NFT and marketplace smart contracts
-   Following [forklog.com](https://forklog.com/sp/dev-on-tezos/en/tezos-introduction) integration for verified creator credentials
-   A wallet will store your keys and can also fulfil other tasks, like signing transactions(https://tezos.b9lab.com/beacon)
---
## Project Organization
-   `Tezos-Test` is organized as a mono repository from which several tests are built and published, following the steps in the link bellow:
-   https://forklog.com/sp/dev-on-tezos/en/tezos-introduction
-   Following the steps in the link bellow( part 1) which contains a resume of previous link and docummentation of advanced contracts in Ocalm(part 2):
-   https://docs.google.com/document/d/13mm3qJd377WW_N7TrCPg9MpG-ooFIM1yk9cGklEQ0Tc/edit?usp=sharing

| Folder                                                    | Utility                                  |
| --------------------------------------------------------- | ---------------------------------------- |
| [`@Tezos-Test/LIGO_test`]                                 | Testing smart contract code              |
| [`@Tezos-Test/taq-test`]                                  | NFT smart contract TypeScript bindings   |
| [`@Tezos-Test/taq-test/token`]                            | Creating an FA 1.2 Token                 |
| [`@ligo`]                                                 | Command to Run docker image              |
| [`@Beacon`]                                               | Beacon is an interface between such a wallet and your application              |

## ligo
A file that help us to manage a issue in ligo Docker Image “ligo: command not found”, it means Docker prematurely closes the LIGO container.

## LIGO_test

A folder containing a test.ligo file which we use as a ligo test for compiling.

## taq-test

A folder containing a collection of contracts and testing file.

-   A collection of NFT and marketplace smart contracts
-   Typescript bindings to enable easy communication with the deployed contracts

## Beacon

Comming soon, next to commit.

