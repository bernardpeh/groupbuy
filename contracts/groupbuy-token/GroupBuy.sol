//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.8;
import "@nomiclabs/buidler/console.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
import "./EthToTokenUniswapV2.sol";

contract GroupBuy is ERC20UpgradeSafe {

    address payable public owner_wallet;
    address public uniswap_router;
    mapping (bytes32 => address) public exchanges;

    function initialize(uint mintAmt) public initializer {
        ERC20UpgradeSafe.__ERC20_init('GROUP BUY TOKEN', 'GROUP');
        // mint 50 million tokens
        _mint(msg.sender,mintAmt);
        owner_wallet = msg.sender;
        // init uniswap address
        exchanges['UniswapV2'] = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    }

    event CreateBuyingOrderUniswapV2Event(uint timeCreated, address buyOrder);

    function createBuyingOrderUniswapV2(uint participant_limit, address token_address, uint waiting_time_mins, bytes32 order_guid, uint tokenAmt, uint ethAmt) public payable returns (bool) {

        EthToTokenUniswapV2 buyOrder = new EthToTokenUniswapV2{value: msg.value}(participant_limit, token_address, exchanges['UniswapV2'], waiting_time_mins, owner_wallet, order_guid, tokenAmt, ethAmt);
        emit CreateBuyingOrderUniswapV2Event(now, address(buyOrder));
    }
}
