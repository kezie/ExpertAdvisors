//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                                         Chikezie |
//|                                              www.chikezie.com.ng |
//+------------------------------------------------------------------+
#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
#property version   "1.00"

#include <CustomIndicator01.mqh>;
#include <Trade/Trade.mqh>
#define EXPERT_MAGIC 555
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

 if (true) {
 
       MqlTick latestPrice; //structure to get the latest prices
       SymbolInfoTick(_Symbol, latestPrice); // Assign current prices to structure 
       
       CTrade trade;
       
       trade.Buy(0.01,NULL,latestPrice.ask,0.00,0.00,NULL);
                    
 
 
 }
   
  }
//+------------------------------------------------------------------+
