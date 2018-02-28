
pragma solidity ^0.4.19;

import './SafeMath.sol';

interface token { 
    function transfer(address receiver, uint amount) public ;
}

contract CustomCrowdSale {
    using SafeMath for uint256;
    
    //addresses
    token public tokenReward;
    address public beneficiary;

    //funds
    uint256 public amountRaised;
    
    //caps
    uint256 public minCap; // the ICO ether goal (in wei)
    uint256 public maxCap; // the ICO ether max cap (in wei)
    
    //time
    uint256 public startTimestamp; // timestamp after which ICO will start
    uint256 public durationInMinutes; // duration of ICO
    
    //mapping
    mapping(address => uint256) public balanceOf;
    
    //logic
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    
    //events
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    /**
    * Constrctor function
    */
     
    function CustomCrowdSale( 
        ) public {
        tokenReward = token(0xDD960d7747737721389aC28B4B95aAb24F714357); // place token contract address of the desired token to be issued. 
        beneficiary = 0xf9fE46227013EFBcc0255b4CEd93192Fe2F6a097;
        startTimestamp;
        minCap = 1 ether;
        maxCap = 1 ether;
        durationInMinutes = 1 weeks;

    }

    /**
     * Fallback function
     * The function without name is the default function that is called whenever anyone sends funds to a contract.
     */
    function () internal isIcoOpen payable {        
        require(!crowdsaleClosed);      // Crowdsale must still be open.
        uint256 amount = calculateTokenAmount(msg.value);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(msg.value);
        tokenReward.transfer(msg.sender, amount); // Transfer Reward tokens to purchaser.
        FundTransfer(msg.sender, amount, true);     // Trigger and publicly log event 
        // immediately transfer ether to fundsWallet
        beneficiary.transfer(msg.value);
    }

    function calculateTokenAmount(uint256 weiAmount) internal constant returns(uint256) {
        
        uint256 tokenAmount;
        if (now <= startTimestamp.add(1 weeks)) {
            // +50% bonus during first week 1 ETH : 3750 Tokens
            tokenAmount = weiAmount.mul(2500).mul(150).div(100);
        } else {
            // standard rate: 1 ETH : 2500 Tokens
            return tokenAmount = weiAmount.mul(2500);
        }
    }

    modifier isIcoOpen() {
        require(now >= startTimestamp);
        require(now <= (startTimestamp.add(durationInMinutes)) || amountRaised < minCap);
        require(amountRaised <= maxCap);
        _;
    }

    modifier isIcoFinished() {
        require(now >= startTimestamp);
        require(amountRaised >= maxCap || (now >= (startTimestamp.add(durationInMinutes)) && amountRaised >= minCap));
        _;
    }
    
    function checkGoalReached() internal isIcoFinished {  // After the deadline.
        if (amountRaised >= maxCap){               // Check if goal was reached.
            fundingGoalReached = true;                  // If goal was reached.
            GoalReached(beneficiary, amountRaised);     // Trigger and publicly log event.
        }
        crowdsaleClosed = true;                         // End this crowdsale. 
    }

    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached beneficiary can withdraw available funds.
     */
    function safeWithdrawal() public isIcoFinished {            // After the deadline.
        checkGoalReached();                                     // Checks is the funding goal was reached.
        if (!fundingGoalReached && beneficiary == msg.sender) { // If funding goal was not reached and Beneficiary is the caller.
            withdraw();                                         // Beneficiary is allowed withdraw funds raised to beneficiary's account.
            FundTransfer(beneficiary, amountRaised, false);     // Trigger and publicly log event. 
            } else {
                fundingGoalReached = true;                      // Funding goal was reached.
            }

        if (fundingGoalReached && beneficiary == msg.sender) {  // If funding goal was reached and Beneficiary is the caller.
            withdraw();                                         // Beneficiary is allowed withdraw funds raised to beneficiary's account.
            FundTransfer(beneficiary, amountRaised, false);     // Trigger and publicly log event.
            } else {
                fundingGoalReached = false;                     // Fund goal was not reached.
            }
    }
    
    function withdraw() internal {
        var cash = amountRaised;
        amountRaised = 0;
        beneficiary.transfer(cash); // transfer all ether to beneficiary address.
    }

}


