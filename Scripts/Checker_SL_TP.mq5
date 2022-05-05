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

      
   input double signalPrice = 1.2995;
   extern int takeProfitPips = 40;
   input int stopLossPips = 30;
      


void OnStart()
  {
//---
   
   
   Alert("");
  

  MqlTick latestPrice; //structure to get the latest prices
  SymbolInfoTick(Symbol(), latestPrice); // Assign current prices to structure 
  
  double PipValue = getPipValue();
  
  Alert(latestPrice.bid);
   
  Alert("Pip value is " + (string)PipValue);
   
   if ( latestPrice.ask < signalPrice) //Buying
   {
   
   Alert("Price is below signalPrice. Sending buy order");
   double stopLossPrice = calculateStopLoss(true, latestPrice.ask, stopLossPips);
   double takeProfitPrice = calculateTakeProfit(true, latestPrice.ask, takeProfitPips);
   Alert("Entry price = " + (string)latestPrice.ask);
   Alert("The takeProfitPrice is " + (string)takeProfitPrice);
   Alert("The stopLossPrice is " + (string)stopLossPrice);
   Alert (latestPrice.ask);
  
  }else if (latestPrice.bid > signalPrice) //shorting
  {
   Alert("Price is above signalPrice. Sending Short order");
   double stopLossPrice = calculateStopLoss(false, latestPrice.bid, stopLossPips);
   double takeProfitPrice = calculateTakeProfit(false, latestPrice.bid, takeProfitPips);
   Alert("Entry price = " + (string)latestPrice.bid);
   Alert("THe stopLossPrice is " + (string)takeProfitPrice);
   Alert("The takeprofitPrice is " + (string)stopLossPrice);
   Alert(latestPrice.bid);
   
   }
   
   
   
  }
//+------------------------------------------------------------------+
