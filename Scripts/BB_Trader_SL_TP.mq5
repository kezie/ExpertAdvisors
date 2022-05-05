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
  /* SetIndexBuffer(0,bb4lowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,bb4upperBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,bb1lowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,bb1mainBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,bb1upperBuffer,INDICATOR_DATA);
   */
   
   
   //sort the price array from the cuurent candle downwards
   ArraySetAsSeries(bb4lowerBuffer,true);
   ArraySetAsSeries(bb4upperBuffer,true);
   ArraySetAsSeries(bb1lowerBuffer,true);
   ArraySetAsSeries(bb1mainBuffer,true);
   ArraySetAsSeries(bb1upperBuffer,true);



   
   /*
   Copy Count
   int bufferCopyCount4 = BarsCalculated(handle4);
   int bufferCopyCount2 = BarsCalculated(handle2);*/

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
   
   
   
   /*Alert("buySlvalue: " + string(buySlvalue) +  "\n shortSlValue: " + string(shortSlValue) + "\n buyValue: " + string(buyValue) + "\n shortValue: " + string(shortValue) + "\n tpValue: " + string(tpValue));
   */
  

  MqlTick latestPrice; //structure to get the latest prices
  SymbolInfoTick(Symbol(), latestPrice); // Assign current prices to structure 
  
  
   
   if ( latestPrice.ask < buyValue) //Buying
   {
   
   Alert("Price is below signalPrice. Sending buy order");
   double stopLossPrice = buySlvalue;
   double takeProfitPrice = tpValue;
   Alert("Entry price = " + (string)latestPrice.ask);
   Alert("The takeProfitPrice is " + (string)takeProfitPrice);
   Alert("The stopLossPrice is " + (string)stopLossPrice);
   Alert (buyValue);
  
  }else if (latestPrice.bid > shortValue) //shorting
  {
   Alert("Price is above signalPrice. Sending Short order");
   double stopLossPrice = shortSlValue;
   double takeProfitPrice = tpValue;
   Alert("Entry price = " + (string)latestPrice.bid);
   Alert("THe stopLossPrice is " + (string)takeProfitPrice);
   Alert("The takeprofitPrice is " + (string)stopLossPrice);
   Alert(shortValue);
   
   }
   

   
  }
//+------------------------------------------------------------------+
