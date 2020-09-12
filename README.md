Sample project to allows users to group buy their favorite tokens in uniswap by using the best tools for the job.

* Truffle - compile, test, running js scripts
* Deploy - openzeppelin cli
* Test EVM - buidler

# Installation
```
npm install
npx oz init
```

# Compile
```
# compile uniswap router and WETH
truffle compile --config config-uniswap-router.js --network development
# compile uniswap factory
truffle compile --config config-uniswap-factory.js --network development
# compile groupbuy token
truffle compile --config config-groupbuy-token.js --network development
```

# Deployment
```
npx oz deploy --skip-compile
```

## Testing

* State buidler as a node (see below)
* deploy UniswapV2Factory
* deploy WETH
* deploy UniswapV2Router02
* depploy Groupbuy Token
* Approve router address in erc20
* Add liquidity to Router
* Group leader create Buying order
* Add participants to Buying order
* Group leader trigger token swap
* Check token status on all participants

```
truffle test --config config-groupbuy-token.js
```

## Accounts
```
npx buidler node

- 0: 0xc783df8a850f42e7F7e57013759C285caa701eB6 (owner)
- 1: 0xeAD9C93b79Ae7C1591b1FB5323BD777E86e150d4 (leader)
- 2: 0xE5904695748fe4A84b40b3fc79De2277660BD1D3 (participant 1)
- 3: 0x92561F28Ec438Ee9831D00D1D59fbDC981b762b2 (participant 2)
- 4: 0x2fFd013AaA7B5a7DA93336C2251075202b33FB2B
- 5: 0x9FC9C2DfBA3b6cF204C37a5F690619772b926e39
- 6: 0xFbC51a9582D031f2ceaaD3959256596C5D3a5468
- 7: 0x84Fae3d3Cba24A97817b2a18c2421d462dbBCe9f
- 8: 0xfa3BdC8709226Da0dA13A4d904c8b66f16c3c8BA
- 9: 0x6c365935CA8710200C7595F0a72EB6023A7706Cd
- 10: 0xD7de703D9BBC4602242D0f3149E5fFCD30Eb3ADF
- 11: 0x532792B73C0C6E7565912E7039C59986f7E1dD1f
- 12: 0xEa960515F8b4C237730F028cBAcF0a28E7F45dE0
- 13: 0x3d91185a02774C70287F6c74Dd26d13DFB58ff16
- 14: 0x5585738127d12542a8fd6C71c19d2E4CECDaB08a
- 15: 0x0e0b5a3F244686Cf9E7811754379B9114D42f78B
- 16: 0x704cF59B16Fd50Efd575342B46Ce9C5e07076A4a
- 17: 0x0a057a7172d0466AEF80976D7E8c80647DfD35e3
- 18: 0x68dfc526037E9030c8F813D014919CC89E7d4d74
- 19: 0x26C43a1D431A4e5eE86cD55Ed7Ef9Edf3641e901
```