//+------------------------------------------------------------------+
//|                                   Position_Trailing_Stoploss.mq5 |
//|                                                         Chikezie |
//|                                              www.chikezie.com.ng |
//+------------------------------------------------------------------+
#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
#property version   "1.00"
#include  <Trade/Trade.mqh>

input int TslTriggerPoints = 5000;
input int TslPoints = 20;

input ENUM_TIMEFRAMES TSLMaTimeFrame = PERIOD_CURRENT;
input int TslMaPeriod = 20;
input ENUM_MA_METHOD TslMaMethod = MODE_SMA;
input ENUM_APPLIED_PRICE TslMaAppPrice = PRICE_CLOSE;

int handleMa;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handleMa = iMA(_Symbol, TSLMaTimeFrame,TslMaPeriod,0,TslMaMethod,TslMaAppPrice);
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
   for (int i = PositionsTotal()-1; i>=0; i--) {
         ulong posTicket = PositionGetTicket(i);
         
         if(PositionSelectByTicket(posTicket)) {
               CTrade trade;
               
               double PosOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double posSL = PositionGetDouble(POSITION_SL);
               double posTP = PositionGetDouble(POSITION_TP);
               double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               
               double ma[];
               CopyBuffer(handleMa,MAIN_LINE,0,1,ma);
               
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
               
                        if(bid >PosOpenPrice + TslTriggerPoints* _Point) {
                              double sl = bid - TslPoints * _Point;
                              
                              if(sl > posSL){
                              
                                    if(trade.PositionModify(posTicket,sl,posTP)) {
                                    
                                          Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                    }
                              
                              }
                        }      
                              
                        if(ArraySize(ma) > 0) {
                        
                              double sl = ma[0];
                              sl = NormalizeDouble(sl, _Digits);
                              
                              if((sl> posSL || posSL == 0) && sl < bid) {
                              
                                    if(trade.PositionModify(posTicket,sl,posTP)) {
                                    
                                       Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                    }
                              }
                        }
                             
                     
                     } else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
                     
                           if(ask <PosOpenPrice-+ TslTriggerPoints* _Point) {
                           double sl = ask + TslPoints * _Point;
                           
                                 if(sl < posSL|| posSL == 0){
                                 
                                       if(trade.PositionModify(posTicket,sl,posTP)) {
                                       
                                             Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                         }
                                 
                                   } 
                             
                             }
                           
                           if(ArraySize(ma) > 0) {
                        
                              double sl = ma[0];
                              sl = NormalizeDouble(sl, _Digits);
                              
                              if((sl< posSL || posSL == 0) && sl > ask) {
                              
                                    if(trade.PositionModify(posTicket,sl,posTP)) {
                                    
                                       Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                      }
                                }
                             }     
                     
                                                         
                        }
         
         }
         
   
   
   
   
   }
  }
//+------------------------------------------------------------------+
