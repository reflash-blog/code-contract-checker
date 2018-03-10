pragma solidity ^0.4.21;

contract Cancellable {
    enum CancelState { None, CanceledByBuyer, CanceledBySeller }
    CancelState public cancelState;
    address public seller;
    address public buyer;

    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }

    function Cancellable() public { cancelState = CancelState.None; }

    function cancelBuyer() public onlyBuyer { 
        if (cancelState == CancelState.CanceledBySeller) selfdestruct(seller);
        else cancelState = CancelState.CanceledByBuyer;
    }

    function cancelSeller() public onlySeller { 
        if (cancelState == CancelState.CanceledBySeller) selfdestruct(seller);
        else cancelState = CancelState.CanceledByBuyer;
    }
}

contract ContractChecker is Cancellable {
    struct Solution {
        string code;
    }

    struct CodeContract {
        string code;
        function(code memory) external callback;
    }

    uint public value;
    CodeContract task;

    function setTask(CodeContract t) public onlySeller {
        task = t;
        value = msg.value;
    }

    function sendSolution(Solution s)
        public
        onlyBuyer
    {
        buyer.transfer(value);
        //seller.transfer(this.balance);
    }
}