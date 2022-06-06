//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                                         Chikezie |
//|                                              www.chikezie.com.ng |
//+------------------------------------------------------------------+
#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
#property version   "1.00"
#property strict
#property script_show_inputs
#define EXPERT_MAGIC 123456

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <CustomIndicator01.mqh>;

   // Program input
   string mySymbol = _Symbol;//Get current Symbol
   input int myPeriod = 20; //Get time period or use default
   input int myShift = 0; //Get shift or use default
   input int slDeviation = 4; // Get slDeviation or use default
   input int mainDeviation = 1; // Get Maindeviation or use default
   input ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE; //get the price to apply
   input ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT; //Get the period to use or use default
   input double risk = 0.02; //Get Maximum Account risk per trade
   
   // Create 4 std BB upper and Lower Modes for TP & SLC
   double bb4upperBuffer[]; 
   double bb4lowerBuffer[];
   
   // Create 2 std BB upper, mid and  Lower Modes for TP & SL    
   double bb1upperBuffer[]; 
   double bb1mainBuffer[];
   double bb1lowerBuffer[];
   
      // Indicator Handles   
   int handle4= iBands(mySymbol,timeFrame,myPeriod,myShift,slDeviation,appliedPrice);

   int handle1= iBands(mySymbol,timeFrame,myPeriod,myShift,mainDeviation,appliedPrice);
   


   
   
   
      
   
void OnStart()
  {
//---

   
   
   //sort the price array from the cuurent candle downwards
   ArraySetAsSeries(bb4lowerBuffer,true);
   ArraySetAsSeries(bb4upperBuffer,true);
   ArraySetAsSeries(bb1lowerBuffer,true);
   ArraySetAsSeries(bb1mainBuffer,true);
   ArraySetAsSeries(bb1upperBuffer,true);



   


   //Copy Buffers
   CopyBuffer(handle4,2,0,3,bb4lowerBuffer);
   CopyBuffer(handle4,1,0,3,bb4upperBuffer);
   CopyBuffer(handle1,0,0,3,bb1mainBuffer);
   CopyBuffer(handle1,1,0,3,bb1upperBuffer);
   CopyBuffer(handle1,2,0,3,bb1lowerBuffer);
   
   //calcualte EA for the cuurent candle
   double buySlvalue= NormalizeDouble(bb4lowerBuffer[0], _Digits);
   double shortSlValue= NormalizeDouble(bb4upperBuffer[0], _Digits);
   double buyValue= NormalizeDouble(bb1lowerBuffer[0], _Digits);
   double shortValue= NormalizeDouble(bb1upperBuffer[0], _Digits);
   double tpValue= NormalizeDouble(bb1mainBuffer[0], _Digits);
   
   
   
   
  if (isTradingAllowed()) {
  
         MqlTick latestPrice; //structure to get the latest prices
  SymbolInfoTick(mySymbol, latestPrice); // Assign current prices to structure 
  
  MqlTradeRequest request = {};
   MqlTradeResult result = {};  
   
   if ( buySlvalue < latestPrice.ask && latestPrice.ask <= buyValue) //Buying
   {
   
   Alert("Price is below signalPrice. Sending buy order");
   
   double optimalVolume = OptimalLotSize(risk,latestPrice.ask,buySlvalue);

  
   //--- prepare a request style taken from internet
   
   request.action=TRADE_ACTION_PENDING;         // setting a pending order
   request.magic= EXPERT_MAGIC;                  // ORDER_MAGIC
   request.symbol= mySymbol;                      // symbol
   request.volume= optimalVolume;                          // Calculated using custom function
   request.sl=buySlvalue;                                // Stop Loss is not specified
   request.tp= tpValue;                                // Take Profit is not specified     
   request.deviation = 10;                         //set slippage
   request.comment = "bought using BB trader";
   //--- form the order type
   request.type= ORDER_TYPE_BUY_LIMIT;                // order type
   //--- form the price for the pending order
   request.price= latestPrice.ask;  // open price
   //--- send a trade request
   int sendOrder = OrderSend(request,result);
   
   if (sendOrder<0) Alert("order rejected. Order error: " + string(GetLastError()));

   
    
   
   //--- write the server reply to log  
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016) Print(result.bid,result.ask,result.price);
   //--- return code of the trade server reply
   Alert( result.retcode);
  
      
   
   
   Alert("Entry price = " + (string)result.ask);
   Alert("The takeProfitPrice is " + (string)tpValue);
   Alert("The stopLossPrice is " + (string)buySlvalue);
   Alert (buyValue);
  
  }else if (shortSlValue > latestPrice.bid && latestPrice.bid >= shortValue) //shorting
  {
   Alert("Price is above signalPrice. Sending Short order");


   double optimalVolume = OptimalLotSize(risk,latestPrice.bid,shortSlValue);
   
   
   //--- prepare a request style taken from internet
   
   request.action=TRADE_ACTION_PENDING;         // setting a pending order
   request.magic= EXPERT_MAGIC;                  // ORDER_MAGIC
   request.symbol= mySymbol;                      // symbol
   request.volume= optimalVolume;                          // calculated using custom lot size function
   request.sl=shortSlValue;                                // Stop Loss is not specified
   request.tp= tpValue;                                // Take Profit is not specified     
   request.deviation = 10;                         //set slippage
   request.comment = "bought using BB trader";
   //--- form the order type
   request.type= ORDER_TYPE_SELL_LIMIT;                // order type
   //--- form the price for the pending order
   request.price= latestPrice.bid;  // open price
   //--- send a trade request
   int sendOrder = OrderSend(request,result);
   
   if (sendOrder<0) Alert("order rejected. Order error: " + string(GetLastError()));

   
   
   //--- write the server reply to log  
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016) Print(result.bid,result.ask,result.price);
   //--- return code of the trade server reply
   Alert( result.retcode);
  
      
   
   
   Alert("Entry price = " + (string)result.bid);
   Alert("The takeProfitPrice is " + (string)tpValue);
   Alert("The stopLossPrice is " + (string)buySlvalue);
   Alert (shortValue);
   
   
   } else {
   
   Alert(" ");
   Alert("No open trades signals");
   }
  
  
  }
  
  
  
  
  
  
  
  
  

   

   
  }
//+------------------------------------------------------------------+
