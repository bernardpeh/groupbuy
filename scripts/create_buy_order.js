const buy_order_contract = '0x44e73999f3e55E4F6b753893502680C51F84817D'
const owner = '0xeAD9C93b79Ae7C1591b1FB5323BD777E86e150d4'
const abi = require('./groupbuy_abi.json')
const token_address = '0x3619DbE27d7c1e7E91aA738697Ae7Bc5FC3eACA5';

async function main() {

    let contract = await new web3.eth.Contract(abi, groupbuy_contract)
    /**
     * participation limit, token_address, waiting_time_mins, order_guid, tokenAmt, ethAmt
     */
    await contract.methods.createBuyingOrderUniswapV2(
        2,
        token_address,
        15,
        web3.utils.toHex('someguid'),
        '0x'+20e18.toString(16),
        '0x'+1e18.toString(16)
        ).send({from: owner, value: 1.1e18}).then((receipt) => {
            console.log(receipt.events)
        })
}

module.exports = function() {
    main();
}
