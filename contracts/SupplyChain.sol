// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {
    // <owner>
    address public owner;

    // <skuCount>
    uint256 public skuCount;

    // Map a sku (number) to an item
    mapping(uint256 => Item) public items;

    // <enum State: ForSale, Sold, Shipped, Received>
    enum State {
        ForSale,
        Sold,
        Shipped,
        Received
    }

    // <struct Item: name, sku, price, state, seller, and buyer>
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    /*
     * Events
     */

    // <LogForSale event: sku arg>
    event LogForSale(uint sku);

    // <LogSold event: sku arg>
    event LogSold(uint sku);

    // <LogShipped event: sku arg>
      event LogShipped(uint sku);

    // <LogReceived event: sku arg>
      event LogReceived(uint sku);

    /*
     * Modifiers
     */

    // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

    // <modifier: isOwner

    modifier verifyCaller(address _address) {
        require (msg.sender == _address);
        _;
    }
// verify that caller has enough money to pay for item
    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }
//send refund to buye, if neccessary 
    modifier checkValue(uint256 _sku) {
        //refund them after pay for item (why it is before, _ checks for logic before func)
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }


    // For each of the following modifiers, use what you learned about modifiers
    // to give them functionality. For example, the forSale modifier should
    // require that the item with the given sku has the state ForSale. 
    //Noted that
    // the uninitialized Item.State is 0, which is also the index of the ForSale
    // value, so checking that Item.State == ForSale is not sufficient to check
    // that an Item is for sale. Hint: What item properties will be non-zero when
    // an Item has been added?

    // modifier forSale
    modifier forSale(uint _sku) {
      require (items[_sku].state == State.ForSale); _;
    }
    // modifier sold

    modifier sold(uint _sku) {
      require(items[_sku].state == State.Sold); _;
    }

      // modifier shipped

  modifier shipped(uint _sku) {
        require (items[_sku].state == State.Shipped); _;
    }

  //modifer recieved
    modifier received(uint _sku) {
        require (items[_sku].state == State.Received); _;
    }


    constructor() public {
        // 1. Set the owner to the transaction sender
        owner = msg.sender;

        // 2. Initialize the sku count to 0. Question, is this necessary?
        skuCount = 0;
    }

    //Add and item and return that an item has been added successfully
    function addItem(string memory _name, uint256 _price)
        public
        returns (bool)
    {
        // 1. Create a new item and put in array
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });

        // 2. Increment the skuCount by one
        skuCount = skuCount + 1;
        // 3. Emit the appropriate event
        emit LogForSale(skuCount);
        // 4. return true
        return true;
    }

   //buy item
    function buyItem(uint256 sku) public payable forSale(sku) paidEnough(items[sku].price) checkValue(sku)  {

   
    items[sku].buyer = msg.sender;
    items[sku].seller.transfer(items[sku].price);
    items[sku].state = State.Sold;

    emit LogSold(sku);


    } 

    //ship item
    function shipItem(uint256 sku) public sold(sku) verifyCaller(items[sku].seller)   {

      // 2. Change the state of the item to shipped.
    items[sku].state = State.Shipped; 
  // 3. call the event associated with this function!
    emit LogShipped(sku);
    }
    // 1. Add modifiers to check
    //    - the item is shipped already
    //    - the person calling this function is the buyer.
    // 2. Change the state of the item to received.
    // 3. Call the event associated with this function!

    //receive item
    function receiveItem(uint256 sku) public  shipped(sku) verifyCaller(items[sku].buyer)   {
    // 2. Change the state of the item to shipped.
    items[sku].state = State.Received; 
  // 3. call the event associated with this function!
    emit LogReceived(sku);
 
}
 //fetch items 
     function fetchItem(uint _sku) public view 
       returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
     { 
      name = items[_sku].name;  
       sku = items[_sku].sku;  
      price = items[_sku].price;  
      state = uint(items[_sku].state);  
      seller = items[_sku].seller;  
      buyer = items[_sku].buyer;  
      return (name, sku, price, state, seller, buyer);  
     } 


    }


  
