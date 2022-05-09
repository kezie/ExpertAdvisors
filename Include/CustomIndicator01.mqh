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
   
   
   //Day of Week Alert
   
            void DayOfWeekAlert()
         {
         
            Alert("");   
               
            MqlDateTime STime;
            datetime time_local=TimeLocal();
            
            TimeToStruct(time_local,STime);
            
         
            
            int dayOfWeek = STime.day_of_week;
            
            switch (dayOfWeek)
            {
               case 1 : Alert("We are Monday. Let's try to enter new trades"); break;
               case 2 : Alert("We are tuesday. Let's try to enter new trades or close existing trades");break;
               case 3 : Alert("We are wednesday. Let's try to enter new trades or close existing trades");break;
               case 4 : Alert("We are thursday. Let's try to enter new trades or close existing trades");break;
               case 5 : Alert("We are friday. Close existing trades");break;
               case 6 : Alert("It's the weekend. No Trading.");break;
               case 0 : Alert("It's the weekend. No Trading.");break;
               default : Alert("Error. No such day in the week.");
            }
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
   
     
     
     
       if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
      Alert("Check if automated trading is allowed in the terminal settings!");
      return false;
      
   }else if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return false;
         
     } else if (!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
      " at the trade server side");
      return false;
      
     } else if  (!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            ".\n Perhaps an investor password has been used to connect to the trading account.",
            "\n Check the terminal journal for the following entry:",
            "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
   return false;
   
   
   } else if (  check.IsTradeAllowed() && find.TradeAllowed()) {
      Alert("Your EA is allowd to trade");
      return true;
   } else {
      Alert("Expert Advisor is NOT Allowed to Trade. Find out why.");
      return false;
   }
   
   
   
   }
   


    // Optimal Lot Size Calculator using risk percent and loss in pips
      
   double OptimalLotSize(double maxRiskPrc, int maxLossInPips){

   double accEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   Print("accEquity: " + (string)accEquity);
  
   
   double lotSize = SymbolInfoDouble(NULL, SYMBOL_TRADE_CONTRACT_SIZE);
   Print("lotSize: " + (string)lotSize);
  
   double tickValue = SymbolInfoDouble(NULL, SYMBOL_TRADE_TICK_VALUE);
  
   if(_Digits <= 3)
   {
   tickValue = tickValue /100;
   }
  
   Print("tickValue: " + (string)tickValue);
  
   double maxLossDollar = accEquity * maxRiskPrc;
   Print("maxLossDollar: " + (string)maxLossDollar);
  
   double maxLossInQuoteCurr = maxLossDollar / tickValue;
   Print("maxLossInQuoteCurr: " + (string)maxLossInQuoteCurr);
  
   double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * getPipValue())/lotSize,2);
  
   return optimalLotSize;
 
   }

   // Optimal Lot Size Calculator 2 using risk percent, entry price and stoploss
   double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
   {
   int maxLossInPips = int(fabs(entryPrice - stopLoss)/getPipValue());
   
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
   }
   
   //Get stoploss Price
      
      double GetStopLossPrice(bool bIsLongPosition, double entryPrice, int maxLossInPips)
   {
      double stopLossPrice;
      if (bIsLongPosition)
      {
         stopLossPrice = entryPrice - maxLossInPips * 0.0001;
      }
      else
      {
         stopLossPrice = entryPrice + maxLossInPips * 0.0001;
      }
      return stopLossPrice;
   }
   
   
   // CHeck Open Orders by Expert Magic Number
   
   bool CheckIfOpenOrdersByMagicNB(int magicNB)
{
   int openOrders = PositionsTotal();
   
   for(int i = 0; i < openOrders; i++)
   {
      if(PositionSelect(PositionGetSymbol(i))==true)
      {
         if(PositionGetInteger(POSITION_MAGIC) == magicNB) 
         {
            return true;
         }  
      }
   }
   return false;
}