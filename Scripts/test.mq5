//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                                         Chikezie |
//|                                              www.chikezie.com.ng |
//+------------------------------------------------------------------+
#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
#property version   "1.00"
#property strict
//#property script_show_inputs
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <CustomIndicator01.mqh>
  #include <Trade\SymbolInfo.mqh>
  #include <Trade\Trade.mqh>;
  
  string mySymbol = _Symbol;
  int openOrderID;
  ulong orderTicket;
  
  CTrade trade;
     
     
       
 

void OnStart()
  {
//---
   
  if (CheckIfOpenOrdersByMagicNB(555)) {
  
  Alert ("Yes");
  }
                           
                           
                           
                                   
   
                           
                        

   
  }
//+------------------------------------------------------------------+



   

