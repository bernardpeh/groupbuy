//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.8;
import "@nomiclabs/buidler/console.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@nomiclabs/buidler/console.sol";

contract EthToTokenUniswapV2 {

    using SafeMath for uint256;

    struct Participant {
        // index 0 is the leader, the person who initiated this contract
        uint index;
        uint tokenAmt;
        uint ethAmt;
        uint ethStaked;
    }

    bytes32 public order_id;
    mapping (address => Participant) public participants;
    uint public createdTime;
    uint public participantLimit;
    // buying window in minutes
    uint public buyingWindow;
    address payable public owner;
    address public uniswap_router;
    address public token;
    address payable[] public addressIndexes;
    uint public constant eth_staked_min = 0.05 ether;

    event EthToTokenBuyOrderCreated(uint createdTime, bytes32 order_id, address buyOrder);
    event Withdrawed(uint time, address participant);
    event Participated(uint time, address participant);
    event Swapped(uint time, uint token_value, address participant);
    event KeyValue(bytes32, uint);

    constructor (uint participant_limit, address token_address, address router_address, uint waiting_time_mins, address payable owner_address, bytes32 id, uint tokenAmt, uint ethAmt) public payable {
        require(msg.value.sub(ethAmt) > eth_staked_min, 'You need to stake 0.05 ETH');
        order_id = id;
        createdTime = now;
        participantLimit = participant_limit;
        buyingWindow = waiting_time_mins;
        owner = owner_address;
        uniswap_router = router_address;
        token = token_address;
        participants[msg.sender] = Participant(0,tokenAmt, ethAmt, msg.value.sub(ethAmt));
        addressIndexes.push(msg.sender);
        emit EthToTokenBuyOrderCreated(createdTime, id, address(this));
    }

    // participate in this buying order
    function participate(uint tokenAmt, uint ethAmt) public payable returns (uint) {
        // can only participate once
        require(participants[msg.sender].tokenAmt == 0,'User already participated in this buying order.');
        addressIndexes.push(msg.sender);
        participants[msg.sender] = Participant(addressIndexes.length-1, tokenAmt, ethAmt, msg.value.sub(ethAmt));
        emit Participated(now, msg.sender);
        return now;
    }

    // allow withdraw after buyingwindow
    function withdraw() public returns (uint time) {
        // if leader withdraws, refund all
        require(now.sub(createdTime) > 60 * buyingWindow, 'Please withdraw later.');
        // check if user participated before
        require(participants[msg.sender].tokenAmt > 0,'You must participate before you can withdraw.');
        // if leader or owner withdraws, withdraw all eth for everyone then destroy the contract,
        // and send remaining amt to leader
        // can only be triggered by leader or owner
        if ((participants[msg.sender].tokenAmt > 0 && participants[msg.sender].index == 0) || msg.sender == owner ) {
            for (uint i=1; i< addressIndexes.length; i++) {
                uint amt = participants[addressIndexes[i]].ethAmt.add(participants[addressIndexes[i]].ethStaked);
                addressIndexes[i].transfer(amt);
                emit Withdrawed(now, addressIndexes[i]);
            }
            selfdestruct(addressIndexes[0]);
        }
        else {
            // if member withdraw, refund only member
            uint amt = participants[msg.sender].ethAmt.add(participants[msg.sender].ethAmt.add(participants[msg.sender].ethStaked));
            msg.sender.transfer(amt);
            emit Withdrawed(now, msg.sender);
            // delete user from participation
            Participant memory deletedParticipant = participants[msg.sender];
            // if index is not the last participant, move the last participant to the deleted participant slot
            if (deletedParticipant.index != addressIndexes.length-1) {
                address payable lastAddress = addressIndexes[addressIndexes.length-1];
                addressIndexes[deletedParticipant.index] = lastAddress;
                participants[lastAddress].index = deletedParticipant.index;
            }
            delete participants[msg.sender];
            addressIndexes.pop();
        }
        return now;
    }
    // conversion rate is to be done prior to this call
    function swap(uint tokenAmt, uint gasPrice) public {
        // can only be triggered by leader or owner
        require ((participants[msg.sender].tokenAmt > 0 && participants[msg.sender].index == 0) || msg.sender == owner);
        // if waiting time expires, refund all and selfdestruct
        if (now.sub(createdTime) > 60 * buyingWindow) {
            withdraw();
        }
        // Build arguments for uniswap router call
        IUniswapV2Router02 router = IUniswapV2Router02(uniswap_router);
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = token;
        // Make the call and give it 30 seconds
        // Set amountOutMin to 0 but no success with larger amounts either
        uint ethTotal = 0;
        for (uint i=0; i <= addressIndexes.length; i++) {
            ethTotal = ethTotal.add(participants[addressIndexes[i]].ethAmt);
        }
        router.swapExactETHForTokens{value: ethTotal}(tokenAmt, path, address(this), now + 30);
        // get balance
        uint tokenReceived = IERC20(token).balanceOf(address(this));
        // calculate how much percent each user holds in the buying order
        // and distribute the token to all users based on their eth share
        for (uint i=0; i <= addressIndexes.length; i++) {
            // get percentage
            uint token_distributed = participants[addressIndexes[i]].ethAmt.div(ethTotal) * tokenReceived;
            IERC20(token).transfer(addressIndexes[i], token_distributed);
            emit Swapped(now, token_distributed, addressIndexes[i]);
        }

        // // leader get all tx fees + 10% of pool and his stake back as a reward to facilitate this order
        uint gas_uniswap = 130000;
        uint gas_token_transfer = 0;
        uint gas_eth_transfer = 0;
        // var to be decided later
        uint gas_this_contract_call = 50000;
        for (uint i=1; i <= addressIndexes.length; i++) {
            gas_token_transfer = gas_token_transfer.add(55000);
            gas_eth_transfer = gas_eth_transfer.add(21000);
        }
        uint tx_fee = gas_uniswap.add(gas_token_transfer).add(gas_eth_transfer).add(gas_this_contract_call).mul(gasPrice);
        uint pool_remainder = address(this).balance.sub(participants[addressIndexes[0]].ethStaked);
        addressIndexes[0].transfer(tx_fee.add(pool_remainder).div(10));
        // rest of users get 80% of whats left
        uint participant_refund = pool_remainder.mul(8).div(10).div(addressIndexes.length-1);
        for (uint i=1; i <= addressIndexes.length; i++) {
            addressIndexes[i].transfer(participant_refund);
        }
        // remaining goes to owner
        selfdestruct(owner);
    }
}