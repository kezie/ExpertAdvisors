//+------------------------------------------------------------------+
//|                                            CustomIndicator01.mqh |
//|                                                         Chikezie |
//|                                              www.chikezie.com.ng |
//+------------------------------------------------------------------+
#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include <Trade\TerminalInfo.mqh>
#include <Trade\AccountInfo.mqh>

   double getPipValue() {
   
      if(Digits() >= 4) 
         {
         return 0.0001;
      }
         else
      return 0.01;
   }
   
   double calculateTakeProfit(bool isLong, double entryPrice, int pips){
  
      double takeProfitPrice;
  
      if(isLong) //Buying
      {
         takeProfitPrice = entryPrice + pips * getPipValue();
      } else 
      {
         takeProfitPrice = entryPrice - pips * getPipValue();
      }
  
      return takeProfitPrice;
   
   }
  
   double calculateStopLoss(bool isLong, double entryPrice, int pips) {
  
      double stopLossPrice;
      if(isLong) //Buying
      {
         stopLossPrice = entryPrice - pips * getPipValue();
      } else //Shorting
      {
         stopLossPrice = entryPrice + pips * getPipValue();
      }
      return stopLossPrice;
   }
   
   /* Custom function to return open price of the current candle. 
   It Uses predefined functions:
   CopyOpen to get live data.
   Symbol to get current symbol.
   PERIOD_CURRENT to get current period.
   ArraySetAsSeries to change default index order*/
   double open() {
   
   
   
   double tick[];
   
   ArraySetAsSeries(tick, true);
   
   CopyOpen(Symbol(), PERIOD_CURRENT, 0, 2, tick);
   
   return tick[0];
   }
   
   //Custom Function to check if trade is allowed
   
   bool isTradingAllowed () {
   CAccountInfo find;
   
   CTerminalInfo check;
   
   if (  check.IsTradeAllowed() && find.TradeAllowed()) {
      return true;
   } else {
      return false;
   }
   
   
   
   }
   
