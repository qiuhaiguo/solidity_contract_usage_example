// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract salaryDistribution {

    enum Property { notExitAccount,controlAccount, normalAccount} 
    enum Status   { disable, enable}
    uint public totalBalance;
    
    struct Account {
        Property accountProperty;
        uint withdrawLimit;
        Status accoutStatus;
    }
    
    
    
    mapping(address => Account) public employeeAccount;
    
    constructor () {
        employeeAccount[msg.sender].accountProperty = Property.controlAccount;
        employeeAccount[msg.sender].accoutStatus = Status.enable;
        employeeAccount[msg.sender].withdrawLimit = 2**100;
    }
    
    modifier isControlAccount (){
        
        require(employeeAccount[msg.sender].accountProperty == Property.controlAccount, "You are not the control account!");
        _;
    }
    
    modifier isWithdrawable (address payable _account,uint _amount) {
        
        require(employeeAccount[_account].accountProperty != Property.notExitAccount, "Error, you are not permit to withdraw!");
        require(employeeAccount[_account].accoutStatus == Status.enable, "Error, your account is disabled!");
        require(_amount<= employeeAccount[_account].withdrawLimit, "Error, exceed the withdraw limit!");
        require(totalBalance >= _amount, "Balance not enough!");
        _;
    }
    
    function deposit() public payable {
        totalBalance += msg.value;
    }
    
    function addAccount(address _account, uint _withdrawLimit) public isControlAccount returns(bool) {
        
        employeeAccount[_account].accountProperty = Property.normalAccount;
        employeeAccount[_account].accoutStatus = Status.enable;
        employeeAccount[_account].withdrawLimit= _withdrawLimit;
        
        return true;
    }
    
    function deleteAccount(address _account) public isControlAccount  returns(bool){
        
        delete(employeeAccount[_account]);
        
        return true;
    }
    
    function disableAccountWithdraw(address _account) public isControlAccount returns(bool) {
        
        employeeAccount[_account].accoutStatus = Status.disable;
        
        return true;
    }
    
    function enableAccountWithdraw(address _account) public isControlAccount returns(bool) {
        
        employeeAccount[_account].accoutStatus = Status.enable;
        
        return true;
    }
    
    function acountBalanceCheck(address _account) public view returns(uint) {
        
        return employeeAccount[_account].withdrawLimit;
    }
    
    function accountStatusCheck(address _account) public view returns(Status) {
        
        return employeeAccount[_account].accoutStatus;
    }
    
    
    function withdrawTo(address payable _account, uint _amount) public isWithdrawable(_account,_amount) returns(bool) {
        
        employeeAccount[_account].withdrawLimit -= _amount;
        totalBalance -= _amount;
        _account.transfer(_amount);
        
        return true;
    }
    
    function destroyContract() public  isControlAccount returns(bool){
        
        selfdestruct(payable(msg.sender));
        return true;
    }
    
    receive() external payable {
        deposit();
    }
}