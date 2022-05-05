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
   string mySymbol = Symbol();//Get current Symbol
   input int myPeriod = 20; //Get time period or use default
   input int myShift = 0; //Get shift or use default
   input int slDeviation = 4; // Get slDeviation or use default
   input int mainDeviation = 1; // Get Maindeviation or use default
   input ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE; //get the price to apply
   input ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT; //Get the period to use or use default
   
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
   
   
   
   
  

  MqlTick latestPrice; //structure to get the latest prices
  SymbolInfoTick(mySymbol, latestPrice); // Assign current prices to structure 
  
  MqlTradeRequest request = {};
   MqlTradeResult result = {};  
   
   if ( buySlvalue < latestPrice.ask && latestPrice.ask <= buyValue) //Buying
   {
   
   Alert("Price is below signalPrice. Sending buy order");
   // Set SL and TP based on current position
   double stopLossPrice = buySlvalue;
   double takeProfitPrice = tpValue;
   
  
//--- prepare a request style taken from internet
   
   request.action=TRADE_ACTION_PENDING;         // setting a pending order
   request.magic= EXPERT_MAGIC;                  // ORDER_MAGIC
   request.symbol=_Symbol;                      // symbol
   request.volume=0.1;                          // volume in 0.1 lots
   request.sl=stopLossPrice;                                // Stop Loss is not specified
   request.tp=takeProfitPrice;                                // Take Profit is not specified     
//--- form the order type
   request.type= ORDER_TYPE_BUY_LIMIT;                // order type
//--- form the price for the pending order
   request.price= latestPrice.ask;  // open price
//--- send a trade request
 /*  MqlTradeResult result={};*/
   OrderSend(request,result);
//--- write the server reply to log  
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016) Print(result.bid,result.ask,result.price);
//--- return code of the trade server reply
   Alert( result.retcode);
  
      
   
   
   Alert("Entry price = " + (string)result.ask);
   Alert("The takeProfitPrice is " + (string)takeProfitPrice);
   Alert("The stopLossPrice is " + (string)stopLossPrice);
   Alert (buyValue);
  
  }else if (shortSlValue > latestPrice.bid && latestPrice.bid >= shortValue) //shorting
  {
   Alert("Price is above signalPrice. Sending Short order");
   // Set SL and TP based on current position
   double stopLossPrice = shortSlValue;
   double takeProfitPrice = tpValue;
   

   
  // Define trade requests my style
   request.action = TRADE_ACTION_PENDING;
   request.comment = "bought using BB trader";
   request.deviation = 10;
   request.magic = EXPERT_MAGIC;
   request.price = latestPrice.bid;
   request.volume = 0.01;
   request.symbol = mySymbol;
   request.sl = shortSlValue;
   request.tp = tpValue;
   request.type = ORDER_TYPE_SELL_LIMIT; 
  
   // Send the order
   OrderSend(request,result); 
   
   //MqlTradeCheckResult
   Alert(" ");   
   Alert(result.retcode);
   
   
   
   Alert("Entry price = " + (string)latestPrice.bid);
   Alert("The stopLossPrice is " + (string)takeProfitPrice);
   Alert("The takeprofitPrice is " + (string)stopLossPrice);
   Alert(shortValue);
   
   } else {
   
   Alert(" ");
   Alert("No open trades signals");
   }
   

   
  }
//+------------------------------------------------------------------+
