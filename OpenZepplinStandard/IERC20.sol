pragma solidity ^0.4.18;

interface IERC20 {

function totalSupply() public constant returns (uint256 totalSupply);
//Get the total token supply
function balanceOf(address _owner) public constant returns (uint256 balance);
//Get the account balance of another account with address _owner
function transfer(address _to, uint256 _value) public returns (bool success);
//Send _value amount of tokens to address _to
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
//Send _value amount of tokens from address _from to address _to
/*The transferFrom method is used for a withdraw workflow, allowing contracts to send 
tokens on your behalf, for example to "deposit" to a contract address and/or to charge
fees in sub-currencies; the command should fail unless the _from account has deliberately
authorized the sender of the message via some mechanism; we propose these standardized APIs for approval: */
function approve(address _spender, uint256 _value) public returns (bool success);
/* Allow _spender to withdraw from your account, multiple times, up to the _value amount. 
If this function is called again it overwrites the current allowance with _value. */
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
//Returns the amount which _spender is still allowed to withdraw from _owner
event Transfer(address indexed _from, address indexed _to, uint256 _value);
//Triggered when tokens are transferred.
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
//Triggered whenever approve(address _spender, uint256 _value) is called.

}