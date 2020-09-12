// truffle exec scripts/add_liquidity_eth.js --network=rinkeby
// CONFIGURATION HERE
const uniswap_router_address = '0x0078371BDeDE8aAc7DeBfFf451B74c5EDB385Af7'
// tokenA: WETH
const WETH = '0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf'
// tokenB: ERC20 Token
const token = '0x3619DbE27d7c1e7E91aA738697Ae7Bc5FC3eACA5'
const uniswap_router_abi = require('./uniswap_route_abi.json')

async function main() {
    try {
        let contract = await new web3.eth.Contract(uniswap_router_abi, uniswap_router_address)

        let res = await contract.methods.getAmountsOut(
            '0x'+1e18.toString(16),
            [WETH, token]
            ).call()
        console.log(web3.utils.fromWei(res[0],'ether')+' WETH to '+web3.utils.fromWei(res[1],'ether')+' token')


    }
    catch(err) {
        console.log(err)
    }
}

module.exports = function() {
    main();
}