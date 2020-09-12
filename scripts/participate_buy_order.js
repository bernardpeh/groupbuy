const buyorder_contract = '0x44e73999f3e55E4F6b753893502680C51F84817D'
const random_user = '0x92561F28Ec438Ee9831D00D1D59fbDC981b762b2'
const abi = require('./buyorder_abi.json')
const token_address = '0x3619DbE27d7c1e7E91aA738697Ae7Bc5FC3eACA5';

async function main() {

    let contract = await new web3.eth.Contract(abi, buyorder_contract)
    /**
     * tokenAmt, ethAmt
     */
    await contract.methods.participate(
        '0x'+10e18.toString(16),
        '0x'+0.5e18.toString(16)
        ).send({from: random_user, value: 1.1e18}).then((receipt) => {
            console.log(receipt.events)
        })
}

module.exports = function() {
    main();
}
