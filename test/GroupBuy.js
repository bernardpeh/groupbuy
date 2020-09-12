const GroupBuy = artifacts.require("GroupBuy");
// const EthToTokenUniswapV2 = artifacts.require("EthToTokenUniswapV2");
const UniswapV2Router02 = artifacts.require("UniswapV2Router02");
const UniswapV2Factory = artifacts.require("UniswapV2Factory");
const WETH9 = artifacts.require("WETH9");

contract("GroupBuy", function(accounts) {
    // instance of contract
    var factory, weth, router, groupbuy;
    // init token with 50
    const tokenAmt = '0x'+(50*Math.pow(10,18)).toString(16);

    // deploy contract before test
    before(async () => {
        // deploy factory
        factory = await UniswapV2Factory.new(accounts[0]);
        // deploy weth
        weth = await WETH9.new();
        // deploy router
        router = await UniswapV2Router02.new(factory.address, weth.address)
        // deploy erc20 token
        groupbuy = await GroupBuy.new();
        // init erc20 token to 50 million token
        await groupbuy.initialize(tokenAmt);
        // approve router to access 50 million token in erc20
        await groupbuy.approve(router.address, tokenAmt);
        // add liquidity to router - add 10 eth for 10 token
        let unixTime = Math.round((new Date()).getTime() / 1000)+120
        await router.addLiquidityETH(
            groupbuy.address,
            '0x'+(10*Math.pow(10,18)).toString(16),
            '0x'+(10*Math.pow(10,18)).toString(16),
            '0x'+(10*Math.pow(10,18)).toString(16),
            accounts[0],
            unixTime, {from: accounts[0], value: '0x'+(10*Math.pow(10,18)).toString(16)});
    });

    describe('AS the owner', () => {
        it('I should have 40 group token', async () => {
            let balance = await groupbuy.balanceOf(accounts[0]);
            assert.equal(40*Math.pow(10,18), balance);
        });
    });
    describe('AS the router', () => {
        it('2 group token should exchange for more than 1 eth', async () => {
            let ethAmt = await router.getAmountsOut(
                '0x'+2e18.toString(16),
                [weth.address, groupbuy.address]
            )
            val = parseFloat(web3.utils.fromWei(ethAmt[1]))
            assert.isAbove(val,1)
        })
    });
});
