const buyorder_contract = '0x44e73999f3e55E4F6b753893502680C51F84817D'
const leader = '0xc783df8a850f42e7F7e57013759C285caa701eB6'
const abi = require('./buyorder_abi.json')

async function main() {

    let contract = await new web3.eth.Contract(abi, buyorder_contract)
    /**
     * tokenAmt, ethAmt
     */
    await contract.methods.swap(
        '0x'+30e18.toString(16),
        '0x'+1e9.toString(16)
    ).send({from: leader}).then((receipt) => {
        console.log(receipt.events)
    })
}

module.exports = function() {
    main();
}
