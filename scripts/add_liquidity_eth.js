// truffle exec scripts/add_liquidity_eth.js --network=rinkeby
// CONFIGURATION HERE
const uniswap_router_address = '0x0078371BDeDE8aAc7DeBfFf451B74c5EDB385Af7'
const test_erc20_address = '0x3619DbE27d7c1e7E91aA738697Ae7Bc5FC3eACA5'
const owner = '0xc783df8a850f42e7F7e57013759C285caa701eB6'

const uniswap_router_abi = require('./uniswap_route_abi.json')

async function main() {
    // increase dateline to 120 secs
    let unixTime = Math.round((new Date()).getTime() / 1000)+60
    console.log('Deadline: '+unixTime)
    try {
        let contract = await new web3.eth.Contract(uniswap_router_abi, uniswap_router_address)

        await contract.methods.addLiquidityETH(
            test_erc20_address,
            '0x'+200e18.toString(16),
            '0x'+10e18.toString(16),
            '0x'+10e18.toString(16),
            owner,
            unixTime).send({from: owner, gasPrice: 1e9, value: 10e18}).then((receipt) => {
               console.log(receipt)
        })

    }
    catch(err) {
        console.log(err)
    }
}

module.exports = function() {
    main();
}