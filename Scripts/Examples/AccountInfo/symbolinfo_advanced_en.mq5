//+------------------------------------------------------------------+
//|                                          SymbolInfo_Advanced.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- String variable for comment
   string com="\r\n";
   StringAdd(com,Symbol());
   StringAdd(com,"\r\n");

//--- Size of standard contract
   double lot_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);

//--- Margin currency
   string margin_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);
   StringAdd(com,StringFormat("Standard currency: %.2f %s",lot_size,margin_currency));
   StringAdd(com,"\r\n");

//--- Leverage
   int leverage=(int)AccountInfoInteger(ACCOUNT_LEVERAGE);
   StringAdd(com,StringFormat("Leverage: 1/%d",leverage));
   StringAdd(com,"\r\n");

//--- Calculate value of contract in account currency
   StringAdd(com,"Margin size to open 1 lot position: ");

//--- Calculate margin using leverage
   double margin=GetMarginForOpening(1,Symbol(),POSITION_TYPE_BUY)/leverage;
   StringAdd(com,DoubleToString(margin,2));
   StringAdd(com," "+AccountInfoString(ACCOUNT_CURRENCY));
   Comment(com);
  }
//+------------------------------------------------------------------+
//|  Return amount of equity needed to open position                 |
//+------------------------------------------------------------------+
double GetMarginForOpening(double lot,string symbol,ENUM_POSITION_TYPE direction)
  {
   double answer=0;

//--- Get contract size
   double lot_size=SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);

//--- Get account currency
   string account_currency=AccountInfoString(ACCOUNT_CURRENCY);

//--- Margin currency   
   string margin_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);

//--- Profit currency
   string profit_currency=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);

//--- Calculation currency
   string calc_currency="";

//--- Reverse quote - true, Direct quote - false
   bool mode;

//--- If profit currency and account currency are equal
   if(profit_currency==account_currency)
     {
      calc_currency=symbol;
      mode=true;
     }
//--- If margin currency and account currency are equal
   if(margin_currency==account_currency)
     {
      calc_currency=symbol;
      //--- Just return the contract value, multiplied by the number of lots
      return(lot*lot_size);
     }
//--- If calculation currency is still not determined
//--- then we have cross currency
   if(calc_currency=="")
     {
      calc_currency=GetSymbolByCurrencies(margin_currency,account_currency);
      mode=true;
      //--- If obtained value is equal to NULL, then this symbol is not found
      if(calc_currency==NULL)
        {
         //--- Lets try to do it reverse
         calc_currency=GetSymbolByCurrencies(account_currency,margin_currency);
         mode=false;
        }
     }
//--- If calculation currency is still not found 
   if(calc_currency=="" || calc_currency==NULL)
     {
      Print(__FUNCTION__,"  Can't find calculation currency for symbol combination "+symbol);
      return(NULL);
     }
//--- We know calculation currency, let's get its last prices
   MqlTick tick;
   SymbolInfoTick(calc_currency,tick);

//--- Now we have everything for calculation 
   double calc_price;

//--- Calculate for Buy
   if(direction==POSITION_TYPE_BUY)
     {
      //--- Reverse quote
      if(mode)
        {
         //--- Calculate using Buy price for reverse quote
         calc_price=tick.ask;
         answer=lot*lot_size*calc_price;
        }
      //--- Direct quote 
      else
        {
         //--- Calculate using Sell price for direct quote
         calc_price=tick.bid;
         answer=lot*lot_size/calc_price;
        }
     }
//--- Calculate for Sell
   if(direction==POSITION_TYPE_SELL)
     {
      //--- Reverse quote
      if(mode)
        {
         //--- Calculate using Sell price for reverse quote
         calc_price=tick.bid;
         answer=lot*lot_size*calc_price;
        }
      //--- Direct quote 
      else
        {
         //--- Calculate using Buy price for direct quote
         calc_price=tick.ask;
         answer=lot*lot_size/calc_price;
        }
     }
//--- Return result - amount of equity in account currency, required to open position in specified volume
   return(answer);
  }
//+------------------------------------------------------------------+
//| Return symbol with specified margin currency and profit currency |
//+------------------------------------------------------------------+
string GetSymbolByCurrencies(string margin_currency,string profit_currency)
  {
//--- In loop process all symbols, that are shown in Market Watch window
   for(int s=0;s<SymbolsTotal(true);s++)
     {
      //--- Get symbol name by number in Market Watch window
      string symbolname=SymbolName(s,true);

      //--- Get margin currency
      string m_cur=SymbolInfoString(symbolname,SYMBOL_CURRENCY_MARGIN);

      //--- Get profit currency (profit on price change)
      string p_cur=SymbolInfoString(symbolname,SYMBOL_CURRENCY_PROFIT);

      //--- If symbol matches both currencies, return symbol name
      if(m_cur==margin_currency && p_cur==profit_currency) return(symbolname);
     }
   return(NULL);
  }
//+------------------------------------------------------------------+
