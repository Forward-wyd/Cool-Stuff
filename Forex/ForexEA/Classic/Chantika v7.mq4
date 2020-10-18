
/*
12/Dec/2014  Chantika V4 
17/Dec/2014  Chantika V5, inline modify, remove RapidManager
18/Dec/2014  Chantika V6, Use External BE/Trailing Loss, adding MaxTrades, change the spread requirement logic ..
*/



#property copyright "Copyright ? 2015 Chantika"

#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import

int Filter = 140;
int Filter_EU = 130; //org 140
int Filter_GU = 170;
int Filter_UJ = 190;

int MagicNumber = 999991;
string TradeComment = "";
int MaxTrades = 3;

double StopLoss = 200.0;  //this is for our BUY/SELL STOP SL 2.3 pips modify, can not put 200 pips, will lose !!!

double NoTrade_Profit_Yet_StopLoss = 200;  //30 pips
//double InTrade_Profit_StopLoss = 23;       //2.3 pips

double Distance = 20.0; // not used !!!
double NoTrade_Profit_Yet_Distance = 300;
double InTrade_Profit_Distance = 20;

double Limit = 22.0;    // 20 will cause order130 error
double NoTrade_Profit_Yet_Limit = 22;  // can not play with this , 20 should be ok!!!
//double InTrade_Profit_Limit = 20;

bool Use_TrailingStep = TRUE;
double Start_Trailing_At = 2.9;  // org 2.9 meaning keep bid/ask distance by x PIPS
double TrailingStep = 0.3;        // org 0.3

bool Use_Set_BreakEven = TRUE;
double LockPips =  0.3;           // org 0.3
double Set_BreakEvenAt = 2.3;   // org 2.3

double MinLots = 0.01;
double MaxLots = 100000000.0;//100000.0;
double Risk = 10;  // org 60
double FixedLots = 0.01;//0.1;
bool UseMM = TRUE;
 double MaxSpreadPlusCommission =0.0 ;//6.3 ok !
 double MaxSpreadPlusCommission_EU = 10.3;//0.6 ok !
 double MaxSpreadPlusCommission_GU = 10.0;//1.0 ok !
 double MaxSpreadPlusCommission_UJ = 10.0;//0.6 ok !

double MaxSpread = 0.3  ;//6.3 ok !
double MaxSpread_EU = 0.4;//0.6 ok !
double MaxSpread_GU = 0.7;//1.0 ok !
double MaxSpread_UJ = 0.6;//0.6 ok !


int MAPeriod = 3;
int MAMethod = 3;
string TimeFilter = "----------Time Filter";
int StartHour = 0;
int StartMinute = 0;
int EndHour = 23;
int EndMinute = 59;

 string IndicatorSetting = "=== Indicator Settings ===";
 int IndicatorToUse = 1;  // 0 = Moving Average ( iMA ), 1 = Envelope (iEnvelope)
 int Env_period = 10;
 double Env_deviation = 0.05; // 0.05
 int Env_shift = 0;

int Env_low_band_price = PRICE_HIGH;
int Env_high_band_price = PRICE_LOW;

bool Timed_Closing = TRUE;  
int Minutes_Buy =  40; //Minute
int Minutes_Sell = 40; 
int Timed_Buy_TakeProfit =  -5;  
int Timed_Sell_TakeProfit = -5;  


int Gi_180 = 0;
double G_pips_184 = 0.0;
int G_digits_192 = 0;
double G_point_196 = 0.0;
int Gi_204;
double Gd_208;
double Gd_216;
double Gd_224;
double Gd_232;
double Gd_240;
double Gd_248;
double Gd_256;
int G_slippage_264 = 3;
bool Gi_268;
double Gd_272;
double Gda_280[30];
int Gi_284 = 0;
string Gs_dummy_288;
string Gs_unused_316 = "";
string Gs_unused_324 = "";
double Gd_336;
double Gd_344;
int G_time_352;
int Gi_356;
int G_datetime_360;
string Gs_364 = "000,000,000";
string Gs_372 = "000,000,255";
int Gi_380;
int Gi_384;
int Gi_388;
int Gi_392 = 40;
double G_timeframe_396 = 240.0;
bool Gi_404 = TRUE;
color G_color_408 = DimGray;
string G_name_412 = "SpreadIndikatorObj";
double Gd_420;
color G_color_428 = Red;
color G_color_432 = DarkGray;
color G_color_436 = SpringGreen;
bool Gi_440 = TRUE;
double G_ihigh_444;
double G_ilow_452;
double Gd_460;
int G_datetime_468;
int D_Factor;
string EASymbol;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   //int timeframe_8;
   ArrayInitialize(Gda_280, 0);
   G_digits_192 = Digits;
   G_point_196 = Point;
   Print("Digits: " + G_digits_192 + " Point: " + DoubleToStr(G_point_196, G_digits_192));
   double lotstep_0 = MarketInfo(Symbol(), MODE_LOTSTEP);
   Gi_204 = MathLog(lotstep_0) / MathLog(0.1);
   Gd_208 = MathMax(MinLots, MarketInfo(Symbol(), MODE_MINLOT));
   Gd_216 = MathMin(MaxLots, MarketInfo(Symbol(), MODE_MAXLOT));
   EASymbol = StringSubstr (Symbol(),0,6);
   
   
   if (EASymbol == "EURUSD") {MaxSpread  = MaxSpread_EU; Filter = Filter_EU;}
   if (EASymbol == "GBPUSD") {MaxSpread  = MaxSpread_GU; Filter = Filter_GU;}
   if (EASymbol == "USDJPY") {MaxSpread  = MaxSpread_UJ; Filter = Filter_UJ;}
   
   //G_digits_192 = Digits;  5
   //G_point_196 = Point;    0.00001
   
   Gd_224 = Risk / 100.0;
   Gd_232 = NormalizeDouble(MaxSpreadPlusCommission * G_point_196, G_digits_192 + 1);
   Gd_240 = NormalizeDouble(Limit * G_point_196, G_digits_192);
   Gd_248 = NormalizeDouble(Distance * G_point_196, G_digits_192);
   Gd_256 = NormalizeDouble(Filter * G_point_196 , G_digits_192);
   Gi_268 = FALSE;
   Gd_272 = NormalizeDouble(G_pips_184 * G_point_196, G_digits_192 + 1);

   
   /*if (!IsTesting()) {
      //f0_8();
      if (Gi_404) {
         timeframe_8 = Period();
         switch (timeframe_8) {
         case PERIOD_M1:
            G_timeframe_396 = 5;
            break;
         case PERIOD_M5:
            G_timeframe_396 = 15;
            break;
         case PERIOD_M15:
            G_timeframe_396 = 30;
            break;
         case PERIOD_M30:
            G_timeframe_396 = 60;
            break;
         case PERIOD_H1:
            G_timeframe_396 = 240;
            break;
         case PERIOD_H4:
            G_timeframe_396 = 1440;
            break;
         case PERIOD_D1:
            G_timeframe_396 = 10080;
            break;
         case PERIOD_W1:
            G_timeframe_396 = 43200;
            break;
         case PERIOD_MN1:
            G_timeframe_396 = 43200;
         }
      }*/
      Gd_420 = 0.0001;
    //  f0_7();
    //  f0_2();
    //  f0_0();
    //  f0_3();
    D_Factor = 1;
	  if(Digits == 3|| Digits == 5) D_Factor = 10;        
   
   return (0);
}
	 	  	 			  	   	  	  	 				    	  	 					    	  	   	   	 	 	   	 	 		  		 					 			 		  	   				 		 		  	      			   			 	 	 	 					  	 			  	 
// 52D46093050F38C27267BCE42543EF60
int deinit() {
   /*if (!IsTesting()) {
      for (int Li_0 = 1; Li_0 <= Gi_392; Li_0++) ObjectDelete("Padding_rect" + Li_0);
      for (int count_4 = 0; count_4 < 10; count_4++) {
         ObjectDelete("BD" + count_4);
         ObjectDelete("SD" + count_4);
      }
      ObjectDelete("time");
      ObjectDelete(G_name_412);
   }
   Comment("");
   ObjectDelete("B3LLogo");
   ObjectDelete("B3LCopy");
   ObjectDelete("FiboUp");
   ObjectDelete("FiboDn");
   ObjectDelete("FiboIn"); */
   return (0);
}
	 	 			  	    		   		  	 				 		   			   	  	  			  						 							 			 				  	    		    	 	 	    	 	    	 	 	 							 	  	 				 				 			  		  	 	
// EA2B2676C28C0DB26D39331A336C6B92
int start() {

   int error_8;
   string Ls_12;
   int ticket_20;
   double price_24;
   bool bool_32;
   double Ld_36;
   double Ld_44;
   double price_60;
   double Ld_112;
   int Li_180;
   int cmd_188;
   double Ld_196;
   double Ld_204;
   double ihigh_68 = iHigh(NULL, 0, 0);
   double ilow_76 = iLow(NULL, 0, 0);
  // double ima_84 = iMA(NULL, 0, MAPeriod, Gi_180, MAMethod, PRICE_LOW, 0);
  // double ima_92 = iMA(NULL, 0, MAPeriod, Gi_180, MAMethod, PRICE_HIGH, 0);
  // double Ld_100 = ima_84 - ima_92;

	double indicator_low;
	double indicator_high;
	double indicator_highlow_diff;
	
	// If indicator setting is 1 then we use Envelope
	if ( IndicatorToUse == 1 )
	{
		indicator_low = iEnvelopes ( NULL, 0, Env_period, MODE_SMA, Env_shift, Env_low_band_price, Env_deviation, MODE_LOWER, 0 );
		indicator_high = iEnvelopes ( NULL,0, Env_period, MODE_SMA, Env_shift, Env_high_band_price, Env_deviation, MODE_UPPER, 0 );
	}	
	// If indicator setting is 0 or any other number then use the default mMoving Average
	else
	{
		indicator_low = iMA ( NULL, 0, MAPeriod, Gi_180, MAMethod, PRICE_LOW, 0 );
		indicator_high = iMA ( NULL, 0, MAPeriod, Gi_180, MAMethod, PRICE_HIGH, 0 );
	}
	indicator_highlow_diff = indicator_low - indicator_high;	

   if (!Gi_268) {
      for (int pos_108 = OrdersHistoryTotal() - 1; pos_108 >= 0; pos_108--) {
         if (OrderSelect(pos_108, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderProfit() != 0.0) {
               if (OrderClosePrice() != OrderOpenPrice()) {
                  if (OrderSymbol() == Symbol()) {
                     Gi_268 = TRUE;
                     Ld_112 = MathAbs(OrderProfit() / (OrderClosePrice() - OrderOpenPrice()));
                     Gd_272 = (-OrderCommission()) / Ld_112;
                     break;
                  }
               }
            }
         }
      }
   }

   double Ld_120 = Ask - Bid;
   ArrayCopy(Gda_280, Gda_280, 0, 1, 29);
   Gda_280[29] = Ld_120;
   if (Gi_284 < 30) Gi_284++;
   double Ld_128 = 0;
   pos_108 = 29;
   for (int count_136 = 0; count_136 < Gi_284; count_136++) {
      Ld_128 += Gda_280[pos_108];
      pos_108--;
   }
   double Ld_140 = Ld_128 / Gi_284;
   double Ld_148 = NormalizeDouble(Ask + Gd_272, G_digits_192);  //Ask + comission
   double Ld_156 = NormalizeDouble(Bid - Gd_272, G_digits_192);  //Bid - comission
   double Ld_164 = NormalizeDouble(Ld_140 + Gd_272, G_digits_192 + 1);
   double Ld_172 = ihigh_68 - ilow_76;
   
   if (Ld_172 > Gd_256) {
      if (Ask < indicator_low/*ima_84*/) Li_180 = -1;  // for BUY
      else
         if (Bid > indicator_high/*ima_92*/) Li_180 = 1; // for SELL
   }
   
   int count_184 = 0;
   for (pos_108 = 0; pos_108 < OrdersTotal(); pos_108++) {
      if (OrderSelect(pos_108, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber) {
            cmd_188 = OrderType();
            if (cmd_188 == OP_BUYLIMIT || cmd_188 == OP_SELLLIMIT) continue; //skip this !
         
         
            double TotalProfit = 0.0; 
            if (OrderSymbol() == Symbol()) {
               count_184++;
               switch (cmd_188) {
               case OP_BUY:
                  if (Distance < 0) break;
                  
                  
                 TotalProfit = (Bid - OrderOpenPrice())/Point/D_Factor;
             
                 /*if (TotalProfit >=3) {
             	     Distance = InTrade_Profit_Distance; 
   	              Limit = InTrade_Profit_Limit;
   	              StopLoss= InTrade_Profit_StopLoss; }
   	           */
   	             if (TotalProfit <=1) {
          	   	  Distance = NoTrade_Profit_Yet_Distance; 
   	              Limit = NoTrade_Profit_Yet_Limit;
   	              StopLoss= NoTrade_Profit_Yet_StopLoss; }      	

                  Gd_248 = NormalizeDouble(Distance * G_point_196, G_digits_192);
                  Gd_240 = NormalizeDouble(Limit * G_point_196, G_digits_192); 
          	
                  Ld_44 = NormalizeDouble(OrderStopLoss(), G_digits_192);
                  price_60 = NormalizeDouble(Bid - Gd_248, G_digits_192);  // Bid - Distance
                  
                  //Print("*****TotalProfit=",TotalProfit, ", Distance=", Distance, ", Bid - Distance", price_60, ", Stoploss=",Ld_44 );
                  
                  if (!((Ld_44 == 0.0 || price_60 > Ld_44))) break;   // Bid - Distance > Stoploss 
                  bool_32 = OrderModify(OrderTicket(), OrderOpenPrice(), price_60, OrderTakeProfit(), 0, Blue);
                  if (!(!bool_32)) break;
                  error_8 = GetLastError();
                  Ls_12 = ErrorDescription(error_8);
                  Print("BUY Modify Error Code: " + error_8 + " Message: " + Ls_12 + " OP: " + DoubleToStr(price_24, G_digits_192) + " SL: " + DoubleToStr(price_60, G_digits_192) + " Bid: " + DoubleToStr(Bid, G_digits_192) + " Ask: " + DoubleToStr(Ask, G_digits_192));
                  
                  break;
                  
               case OP_SELL:
                  if (Distance < 0) break;
                  
                   
                 TotalProfit = (OrderOpenPrice()- Ask)/Point/D_Factor;
                  /*if (TotalProfit >=2) {
             	     Distance = InTrade_Profit_Distance; 
   	              Limit = InTrade_Profit_Limit;
   	              StopLoss= InTrade_Profit_StopLoss; }
   	            */
   	             if (TotalProfit <= 1) {
          	   	  Distance = NoTrade_Profit_Yet_Distance; 
   	              Limit = NoTrade_Profit_Yet_Limit;
   	              StopLoss= NoTrade_Profit_Yet_StopLoss; }      	
          
                  Gd_248 = NormalizeDouble(Distance * G_point_196, G_digits_192);
                  Gd_240 = NormalizeDouble(Limit * G_point_196, G_digits_192); 
          	          
                  Ld_44 = NormalizeDouble(OrderStopLoss(), G_digits_192);
                  price_60 = NormalizeDouble(Ask + Gd_248, G_digits_192);
                  if (!((Ld_44 == 0.0 || price_60 < Ld_44))) break;
                  bool_32 = OrderModify(OrderTicket(), OrderOpenPrice(), price_60, OrderTakeProfit(), 0, Red);
                  if (!(!bool_32)) break;
                  error_8 = GetLastError();
                  Ls_12 = ErrorDescription(error_8);
                  Print("SELL Modify Error Code: " + error_8 + " Message: " + Ls_12 + " OP: " + DoubleToStr(price_24, G_digits_192) + " SL: " + DoubleToStr(price_60, G_digits_192) + " Bid: " + DoubleToStr(Bid, G_digits_192) + " Ask: " + DoubleToStr(Ask, G_digits_192));
                  
                  break;
                  
               case OP_BUYSTOP:
                  price_24 = NormalizeDouble(Ask + Gd_240, G_digits_192);  // Ask + Limit
                  Ld_36 = NormalizeDouble(OrderOpenPrice(), G_digits_192);
                  if (!((price_24 < Ld_36))) break;  // If Ask + Limit > Buystop OpenPrice , Go to modify...  
                  price_60 = NormalizeDouble(price_24 - StopLoss * Point, G_digits_192);
                  bool_32 = OrderModify(OrderTicket(), price_24, price_60, OrderTakeProfit(), 0, Lime);
                  if (!(!bool_32)) break;
                  error_8 = GetLastError();
                  Ls_12 = ErrorDescription(error_8);
                  Print("BUYSTOP Modify Error Code: " + error_8 + " Message: " + Ls_12 + " OP: " + DoubleToStr(price_24, G_digits_192) + " SL: " + DoubleToStr(price_60, G_digits_192) + " Bid: " + DoubleToStr(Bid, G_digits_192) + " Ask: " + DoubleToStr(Ask, G_digits_192));
                  break;
               case OP_SELLSTOP:
                  Ld_36 = NormalizeDouble(OrderOpenPrice(), G_digits_192);
                  price_24 = NormalizeDouble(Bid - Gd_240, G_digits_192);
                  if (!((price_24 > Ld_36))) break;
                  price_60 = NormalizeDouble(price_24 + StopLoss* Point, G_digits_192);
                  bool_32 = OrderModify(OrderTicket(), price_24, price_60, OrderTakeProfit(), 0, Orange);
                  if (!(!bool_32)) break;
                  error_8 = GetLastError();
                  Ls_12 = ErrorDescription(error_8);
                  Print("SELLSTOP Modify Error Code: " + error_8 + " Message: " + Ls_12 + " OP: " + DoubleToStr(price_24, G_digits_192) + " SL: " + DoubleToStr(price_60, G_digits_192) + " Bid: " + DoubleToStr(Bid, G_digits_192) + " Ask: " + DoubleToStr(Ask, G_digits_192));
                  break;

               }
            }
         }
      }
   }
   
  double pp, pd;
   if (Digits < 4) {
      pp = 0.01;
      pd = 2;
   } else {
      pp = 0.0001;
      pd = 4;
   }
   
   
      Ld_196 = AccountBalance() * AccountLeverage() * Gd_224;
      if (!UseMM) Ld_196 = FixedLots;
      Ld_204 = NormalizeDouble(Ld_196 / MarketInfo(Symbol(), MODE_LOTSIZE), Gi_204);
      Ld_204 = MathMax(Gd_208, Ld_204);
      Ld_204 = MathMin(Gd_216, Ld_204);
   
   if (count_184 /*== 0*/ <= MaxTrades -1 && Li_180 != 0 /*&& Ld_164 <= Gd_232*/ && NormalizeDouble(Ask - Bid, Digits) < NormalizeDouble(MaxSpread * pp, pd + 1) && f0_4()) {  // New BUY STOP & SELL STOP Orders placed here..
      if (Li_180 == -1) {
         price_24 = NormalizeDouble(Ask + Gd_240, G_digits_192);
         price_60 = NormalizeDouble(price_24 -  200/*StopLoss*/ * Point, G_digits_192);
         ticket_20 = OrderSend(Symbol(), OP_BUYSTOP, Ld_204, price_24, G_slippage_264, price_60, 0, TradeComment, MagicNumber, 0, Lime);
         if (ticket_20 <= 0) {
            error_8 = GetLastError();
            Ls_12 = ErrorDescription(error_8);
            Print("BUYSTOP Send Error Code: " + error_8 + " Message: " + Ls_12 + " LT: " + DoubleToStr(Ld_204, Gi_204) + " OP: " + DoubleToStr(price_24, G_digits_192) + " SL: " + DoubleToStr(price_60, G_digits_192) + " Bid: " + DoubleToStr(Bid, G_digits_192) + " Ask: " + DoubleToStr(Ask, G_digits_192));
          }
       }  
      if (Li_180 == 1) {
          price_24 = NormalizeDouble(Bid - Gd_240, G_digits_192);
          price_60 = NormalizeDouble(price_24 +  200 /*StopLoss*/  * Point, G_digits_192);
          ticket_20 = OrderSend(Symbol(), OP_SELLSTOP, Ld_204, price_24, G_slippage_264, price_60, 0, TradeComment, MagicNumber, 0, Orange);
          if (ticket_20 <= 0) {
            error_8 = GetLastError();
            Ls_12 = ErrorDescription(error_8);
            Print("SELLSTOP Send Error Code: " + error_8 + " Message: " + Ls_12 + " LT: " + DoubleToStr(Ld_204, Gi_204) + " OP: " + DoubleToStr(price_24, G_digits_192) + " SL: " +  DoubleToStr(price_60, G_digits_192) + " Bid: " + DoubleToStr(Bid, G_digits_192) + " Ask: " + DoubleToStr(Ask, G_digits_192));
         }
      }
   }
   string Ls_212 
   = "  \n\n Next Lot:     " + DoubleToStr(Ld_204, G_digits_192)
   + "  \n\n Current Spread:   " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD) / MathPow(10, Digits - pd), Digits - pd) 
   + IIFs((MarketInfo(Symbol(), MODE_SPREAD) / MathPow(10, Digits - pd))> MaxSpread, "    ***Exceeding MaxSpread at:  " + DoubleToStr(MaxSpread, Digits -pd ),"  ,  MaxSpread:  "+DoubleToStr(MaxSpread, Digits - pd))
   + "  \n AvgSpread:      " + DoubleToStr(Ld_140, G_digits_192) 
   + "  \n Commission rate:" + DoubleToStr(Gd_272, G_digits_192 + 1) 
   + "  \n Real avg.spread:" + DoubleToStr(Ld_164, G_digits_192 + 1);
   
   
   if (Ld_164 > Gd_232) {
      Ls_212 = Ls_212 
         + "\n\n" 
         + "  **The EA can not run with this spread ( " + DoubleToStr(Ld_164, G_digits_192 + 1) + " > " + DoubleToStr(Gd_232, G_digits_192 + 1) + " )";
   }
   //if (count_184 != 0 || Li_180 != 0) {
   //}
   
   Comment(Ls_212);
   
   /*if (!IsTesting()) {
      f0_2();
      f0_7();
      f0_0();
      f0_3();
      f0_8();
   }*/
   
   TimedClosing();
   RapidTrailingStop();
   
   return (0);
}

void TimedClosing() {

  if (!Timed_Closing) return;  
   int DC_Digits;  
   bool TicketClose;  
   int ExpirationBuyTime,ExpirationSellTime,MinBuyProfit,MinSellProfit;


  if (Digits == 4 || Digits == 2) DC_Digits = 1;
   else
      if (Digits == 5 || Digits == 3) DC_Digits = 10;
   
    ExpirationBuyTime=Minutes_Buy;
    ExpirationSellTime=Minutes_Sell;
    MinBuyProfit=Timed_Buy_TakeProfit*DC_Digits;
    MinSellProfit=Timed_Sell_TakeProfit*DC_Digits;

   int total = OrdersTotal();
   for (int i = total - 1; i >= 0; i--) {
      
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == TRUE) { 
      if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber ) {
         if (TimeCurrent() - OrderOpenTime() >= 60 * ExpirationBuyTime && Bid >= OrderOpenPrice() + MinBuyProfit * Point) {
            RefreshRates();
            TicketClose = OrderClose(OrderTicket(), OrderLots(), Bid, G_slippage_264 , Blue);
            if (!TicketClose) {
            	Print("There was an error closing the trade. Error is:", GetLastError());
              return;
             }
           }
         }
       }
         
      if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (TimeCurrent() - OrderOpenTime() >= 60 * ExpirationSellTime && Ask <= OrderOpenPrice() - MinSellProfit * Point) {
            RefreshRates();
            TicketClose = OrderClose(OrderTicket(), OrderLots(), Ask, G_slippage_264, Red);
            //---
            if (!TicketClose) {
              Print("There was an error closing the trade. Error is:", GetLastError());
              return;
             }
          }
        }
      }
  }
      
			 	   	    	 			 						 				 			 		 	 	   				    	  	   		  	   		 		  	   	 				 		  		 			 	  	 		  		 		 	  				  	  		     		   					 	   
// 3B8B9927CE5F3E077818404E64D1C252
int f0_4() {
   if ((Hour() > StartHour && Hour() < EndHour) || (Hour() == StartHour && Minute() >= StartMinute) || (Hour() == EndHour && Minute() < EndMinute)) return (1);
   return (0);
}
	  				  			  		  	 	  	 	  	 		  	 		   				  												 							 		 			 	 	          	  		    		     	  		 				  	 	  		 			 		   			      	 	
// DFF63C921B711879B02EDBCAFB9A05B0
void f0_8() {
   Gd_336 = WindowPriceMax();
   Gd_344 = WindowPriceMin();
   G_time_352 = Time[WindowFirstVisibleBar()];
   Gi_356 = WindowFirstVisibleBar() - WindowBarsPerChart();
   if (Gi_356 < 0) Gi_356 = 0;
   G_datetime_360 = Time[Gi_356] + 60 * Period();
   for (int Li_0 = 1; Li_0 <= Gi_392; Li_0++) {
      if (ObjectFind("Padding_rect" + Li_0) == -1) ObjectCreate("Padding_rect" + Li_0, OBJ_RECTANGLE, 0, G_time_352, Gd_336 - (Gd_336 - Gd_344) / Gi_392 * (Li_0 - 1), G_datetime_360, Gd_336 - (Gd_336 - Gd_344) / Gi_392 * Li_0);
      ObjectSet("Padding_rect" + Li_0, OBJPROP_TIME1, G_time_352);
      ObjectSet("Padding_rect" + Li_0, OBJPROP_TIME2, G_datetime_360 - 1);
      ObjectSet("Padding_rect" + Li_0, OBJPROP_PRICE1, Gd_336 - (Gd_336 - Gd_344) / Gi_392 * (Li_0 - 1));
      ObjectSet("Padding_rect" + Li_0, OBJPROP_PRICE2, Gd_336 - (Gd_336 - Gd_344) / Gi_392 * Li_0);
      ObjectSet("Padding_rect" + Li_0, OBJPROP_BACK, TRUE);
      ObjectSet("Padding_rect" + Li_0, OBJPROP_COLOR, f0_9(Gs_364, Gs_372, Gi_392, Li_0));
   }
   WindowRedraw();
}
	 	 	 	  	   			   			 	 							   		    	  		 			  	 				 		 				 		  				       		 	  	 	 		   	 	 	  	 	 											  	 		 	 				  		  		 		 	
// F7E068A881FC08598B50EAA72BECD80C
int f0_9(string As_0, string As_8, int Ai_16, int Ai_20) {
   int str2int_24 = StrToInteger(StringSubstr(As_0, 0, 3));
   int str2int_28 = StrToInteger(StringSubstr(As_0, 4, 3));
   int str2int_32 = StrToInteger(StringSubstr(As_0, 8, 3));
   int str2int_36 = StrToInteger(StringSubstr(As_8, 0, 3));
   int str2int_40 = StrToInteger(StringSubstr(As_8, 4, 3));
   int str2int_44 = StrToInteger(StringSubstr(As_8, 8, 3));
   if (str2int_24 > str2int_36) Gi_380 = str2int_24 + (str2int_36 - str2int_24) / Ai_16 * Ai_20;
   if (str2int_24 < str2int_36) Gi_380 = str2int_24 - (str2int_24 - str2int_36) / Ai_16 * Ai_20;
   if (str2int_28 > str2int_40) Gi_384 = str2int_28 + (str2int_40 - str2int_28) / Ai_16 * Ai_20;
   if (str2int_28 < str2int_40) Gi_384 = str2int_28 - (str2int_28 - str2int_40) / Ai_16 * Ai_20;
   if (str2int_32 > str2int_44) Gi_388 = str2int_32 + (str2int_44 - str2int_32) / Ai_16 * Ai_20;
   if (str2int_32 < str2int_44) Gi_388 = str2int_32 - (str2int_32 - str2int_44) / Ai_16 * Ai_20;
   Gi_384 *= 256;
   Gi_388 <<= 16;
   return (Gi_380 + Gi_384 + Gi_388);
}
			 			       		 	 		  	  			 		 	 			      	  		   					  						  			 		 	  	   			    			 	      	    			 	 			 			 	    				 	 		 			 			  	 	
// 2795031E32D1FE85C9BD72823A8B4142
void f0_2() {
   double Lda_0[10];
   double Lda_4[10];
   double Lda_8[10];
   double Lda_12[10];
   int Li_16;
   int Li_20;
   int Li_24;
   int Li_32;
   if (Period() < G_timeframe_396) {
      ArrayCopySeries(Lda_0, 2, Symbol(), G_timeframe_396);
      ArrayCopySeries(Lda_4, 1, Symbol(), G_timeframe_396);
      ArrayCopySeries(Lda_8, 0, Symbol(), G_timeframe_396);
      ArrayCopySeries(Lda_12, 3, Symbol(), G_timeframe_396);
      Li_32 = 3;
      for (int Li_28 = 2; Li_28 >= 0; Li_28--) {
         Li_20 = Time[0] + Period() * (90 * Li_32);
         Li_24 = Time[0] + 90 * (Period() * (Li_32 + 1));
         if (ObjectFind("BD" + Li_28) == -1) {
            if (Lda_8[Li_28] > Lda_12[Li_28]) Li_16 = 170;
            else Li_16 = 43520;
            f0_6("D" + Li_28, Li_20, Li_24, Lda_8[Li_28], Lda_12[Li_28], Lda_4[Li_28], Lda_0[Li_28], Li_16);
         } else {
            if (Lda_8[Li_28] > Lda_12[Li_28]) Li_16 = 170;
            else Li_16 = 43520;
            f0_5("D" + Li_28, Li_20, Li_24, Lda_8[Li_28], Lda_12[Li_28], Lda_4[Li_28], Lda_0[Li_28], Li_16);
         }
         Li_32++;
         Li_32++;
      }
   }
}
			  	  	   	  			 	  			 		   			 	 		 	     		     	 	   	 	 	   	 			  	 			 					 	  		   	 	  		 	  		    	  		    	  	 	    				 						    
// 9F92396C933453E2D1202389D9EFB0E5
void f0_6(string As_0, int A_datetime_8, int A_datetime_12, double A_price_16, double A_price_24, double A_price_32, double A_price_40, color A_color_48) {
   if (A_price_16 == A_price_24) A_color_48 = Gray;
   ObjectCreate("B" + As_0, OBJ_RECTANGLE, 0, A_datetime_8, A_price_16, A_datetime_12, A_price_24);
   ObjectSet("B" + As_0, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("B" + As_0, OBJPROP_COLOR, A_color_48);
   ObjectSet("B" + As_0, OBJPROP_BACK, TRUE);
   int datetime_52 = A_datetime_8 + (A_datetime_12 - A_datetime_8) / 2;
   ObjectCreate("S" + As_0, OBJ_TREND, 0, datetime_52, A_price_32, datetime_52, A_price_40);
   ObjectSet("S" + As_0, OBJPROP_COLOR, A_color_48);
   ObjectSet("S" + As_0, OBJPROP_BACK, TRUE);
   ObjectSet("S" + As_0, OBJPROP_RAY, FALSE);
   ObjectSet("S" + As_0, OBJPROP_WIDTH, 2);
}
		   	    	 	  	 			  		   	   	 			 		   	   			 	  	 		 		 	 		 		 				   			  	 		 	 		    	   			 	 		     		  	      		 	  	  			 	 	 		   	
// 88F07BF2A3E2A04159AC984719B3F549
void f0_5(string As_0, int A_datetime_8, int A_datetime_12, double Ad_16, double Ad_24, double Ad_32, double Ad_40, color A_color_48) {
   if (Ad_16 == Ad_24) A_color_48 = Gray;
   ObjectSet("B" + As_0, OBJPROP_TIME1, A_datetime_8);
   ObjectSet("B" + As_0, OBJPROP_PRICE1, Ad_16);
   ObjectSet("B" + As_0, OBJPROP_TIME2, A_datetime_12);
   ObjectSet("B" + As_0, OBJPROP_PRICE2, Ad_24);
   ObjectSet("B" + As_0, OBJPROP_BACK, TRUE);
   ObjectSet("B" + As_0, OBJPROP_COLOR, A_color_48);
   int datetime_52 = A_datetime_8 + (A_datetime_12 - A_datetime_8) / 2;
   ObjectSet("S" + As_0, OBJPROP_TIME1, datetime_52);
   ObjectSet("S" + As_0, OBJPROP_PRICE1, Ad_32);
   ObjectSet("S" + As_0, OBJPROP_TIME2, datetime_52);
   ObjectSet("S" + As_0, OBJPROP_PRICE2, Ad_40);
   ObjectSet("S" + As_0, OBJPROP_BACK, TRUE);
   ObjectSet("S" + As_0, OBJPROP_WIDTH, 2);
   ObjectSet("S" + As_0, OBJPROP_COLOR, A_color_48);
}
		 	 				 			 	 			     	     	 			  	 		 		      		 		   	  		   	  	     			 			  	  	 	 	   		 	 	  	 	 	  	       			 	  			    			 		  	 		 
// CDF7118C61A4AA4E389CF2547874D314
void f0_7() {
   double Ld_0 = (Ask - Bid) / Gd_420;
   string text_8 = "Spread: " + DoubleToStr(Ld_0, 1) + " pips";
   if (ObjectFind(G_name_412) < 0) {
      ObjectCreate(G_name_412, OBJ_LABEL, 0, 0, 0);
      ObjectSet(G_name_412, OBJPROP_CORNER, 1);
      ObjectSet(G_name_412, OBJPROP_YDISTANCE, 260);
      ObjectSet(G_name_412, OBJPROP_XDISTANCE, 10);
      ObjectSetText(G_name_412, text_8, 13, "Arial", G_color_408);
   }
   ObjectSetText(G_name_412, text_8);
   WindowRedraw();
}
	 					  	 	  		    	  	 		 	 		    		   	 		  			 							  						  		 					 	    	     	 			    	      	 			 					 	 	  	  			 			  			  	   	 	
// 39C409D2E4985FE63B2929843BE560CF
void f0_3() {
   int Li_8 = Time[0] + 60 * Period() - TimeCurrent();
   double Ld_0 = Li_8 / 60.0;
   int Li_12 = Li_8 % 60;
   Li_8 = (Li_8 - Li_8 % 60) / 60;
   Comment(Li_8 + " minutes " + Li_12 + " seconds left to bar end");
   ObjectDelete("time");
   if (ObjectFind("time") != 0) {
      ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0] + 0.0005);
      ObjectSetText("time", "                                 <--" + Li_8 + ":" + Li_12, 13, "Verdana", Yellow);
      return;
   }
   ObjectMove("time", 0, Time[0], Close[0] + 0.0005);
}
	 			   		 	 	 		   							 		 		   	 	 		 					 	 		  	 	  	  	 	  	 		 			  	 	 	  		   					 		   		   				 	 		 		  		  	    		    		 	  	   
// 0D09CCEE6F8BC2AF782594ED51D3E1A7
void f0_0() {
   int Li_0 = iBarShift(NULL, PERIOD_D1, Time[0]) + 1;
   G_ihigh_444 = iHigh(NULL, PERIOD_D1, Li_0);
   G_ilow_452 = iLow(NULL, PERIOD_D1, Li_0);
   G_datetime_468 = iTime(NULL, PERIOD_D1, Li_0);
   if (TimeDayOfWeek(G_datetime_468) == 0) {
      G_ihigh_444 = MathMax(G_ihigh_444, iHigh(NULL, PERIOD_D1, Li_0 + 1));
      G_ilow_452 = MathMin(G_ilow_452, iLow(NULL, PERIOD_D1, Li_0 + 1));
   }
   Gd_460 = G_ihigh_444 - G_ilow_452;
   f0_1();
}
	 	 			  	    		   		  	 				 		   			   	  	  			  						 							 			 				  	    		    	 	 	    	 	    	 	 	 							 	  	 				 				 			  		  	 	
// 177469F06A7487E6FDDCBE94FDB6FD63
int f0_1() {
   if (ObjectFind("FiboUp") == -1) ObjectCreate("FiboUp", OBJ_FIBO, 0, G_datetime_468, G_ihigh_444 + Gd_460, G_datetime_468, G_ihigh_444);
   else {
      ObjectSet("FiboUp", OBJPROP_TIME2, G_datetime_468);
      ObjectSet("FiboUp", OBJPROP_TIME1, G_datetime_468);
      ObjectSet("FiboUp", OBJPROP_PRICE1, G_ihigh_444 + Gd_460);
      ObjectSet("FiboUp", OBJPROP_PRICE2, G_ihigh_444);
   }
   ObjectSet("FiboUp", OBJPROP_LEVELCOLOR, G_color_428);
   ObjectSet("FiboUp", OBJPROP_FIBOLEVELS, 13);
   ObjectSet("FiboUp", OBJPROP_FIRSTLEVEL, 0.0);
   ObjectSetFiboDescription("FiboUp", 0, "(100.0%) -  %$");
   ObjectSet("FiboUp", 211, 0.236);
   ObjectSetFiboDescription("FiboUp", 1, "(123.6%) -  %$");
   ObjectSet("FiboUp", 212, 0.382);
   ObjectSetFiboDescription("FiboUp", 2, "(138.2%) -  %$");
   ObjectSet("FiboUp", 213, 0.5);
   ObjectSetFiboDescription("FiboUp", 3, "(150.0%) -  %$");
   ObjectSet("FiboUp", 214, 0.618);
   ObjectSetFiboDescription("FiboUp", 4, "(161.8%) -  %$");
   ObjectSet("FiboUp", 215, 0.764);
   ObjectSetFiboDescription("FiboUp", 5, "(176.4%) -  %$");
   ObjectSet("FiboUp", 216, 1.0);
   ObjectSetFiboDescription("FiboUp", 6, "(200.0%) -  %$");
   ObjectSet("FiboUp", 217, 1.236);
   ObjectSetFiboDescription("FiboUp", 7, "(223.6%) -  %$");
   ObjectSet("FiboUp", 218, 1.5);
   ObjectSetFiboDescription("FiboUp", 8, "(250.0%) -  %$");
   ObjectSet("FiboUp", 219, 1.618);
   ObjectSetFiboDescription("FiboUp", 9, "(261.8%) -  %$");
   ObjectSet("FiboUp", 220, 2.0);
   ObjectSetFiboDescription("FiboUp", 10, "(300.0%) -  %$");
   ObjectSet("FiboUp", 221, 2.5);
   ObjectSetFiboDescription("FiboUp", 11, "(350.0%) -  %$");
   ObjectSet("FiboUp", 222, 3.0);
   ObjectSetFiboDescription("FiboUp", 12, "(400.0%) -  %$");
   ObjectSet("FiboUp", 223, 3.5);
   ObjectSetFiboDescription("FiboUp", 13, "(450.0%) -  %$");
   ObjectSet("FiboUp", 224, 4.0);
   ObjectSetFiboDescription("FiboUp", 14, "(500.0%) -  %$");
   ObjectSet("FiboUp", OBJPROP_RAY, TRUE);
   ObjectSet("FiboUp", OBJPROP_BACK, TRUE);
   if (ObjectFind("FiboDn") == -1) ObjectCreate("FiboDn", OBJ_FIBO, 0, G_datetime_468, G_ilow_452 - Gd_460, G_datetime_468, G_ilow_452);
   else {
      ObjectSet("FiboDn", OBJPROP_TIME2, G_datetime_468);
      ObjectSet("FiboDn", OBJPROP_TIME1, G_datetime_468);
      ObjectSet("FiboDn", OBJPROP_PRICE1, G_ilow_452 - Gd_460);
      ObjectSet("FiboDn", OBJPROP_PRICE2, G_ilow_452);
   }
   ObjectSet("FiboDn", OBJPROP_LEVELCOLOR, G_color_436);
   ObjectSet("FiboDn", OBJPROP_FIBOLEVELS, 19);
   ObjectSet("FiboDn", OBJPROP_FIRSTLEVEL, 0.0);
   ObjectSetFiboDescription("FiboDn", 0, "(0.0%) -  %$");
   ObjectSet("FiboDn", 211, 0.236);
   ObjectSetFiboDescription("FiboDn", 1, "(-23.6%) -  %$");
   ObjectSet("FiboDn", 212, 0.382);
   ObjectSetFiboDescription("FiboDn", 2, "(-38.2%) -  %$");
   ObjectSet("FiboDn", 213, 0.5);
   ObjectSetFiboDescription("FiboDn", 3, "(-50.0%) -  %$");
   ObjectSet("FiboDn", 214, 0.618);
   ObjectSetFiboDescription("FiboDn", 4, "(-61.8%) -  %$");
   ObjectSet("FiboDn", 215, 0.764);
   ObjectSetFiboDescription("FiboDn", 5, "(-76.4%) -  %$");
   ObjectSet("FiboDn", 216, 1.0);
   ObjectSetFiboDescription("FiboDn", 6, "(-100.0%) -  %$");
   ObjectSet("FiboDn", 217, 1.236);
   ObjectSetFiboDescription("FiboDn", 7, "(-123.6%) -  %$");
   ObjectSet("FiboDn", 218, 1.382);
   ObjectSetFiboDescription("FiboDn", 8, "(-138.2%) -  %$");
   ObjectSet("FiboDn", 219, 1.5);
   ObjectSetFiboDescription("FiboDn", 9, "(-150.0%) -  %$");
   ObjectSet("FiboDn", 220, 1.618);
   ObjectSetFiboDescription("FiboDn", 10, "(-161.8%) -  %$");
   ObjectSet("FiboDn", 221, 1.764);
   ObjectSetFiboDescription("FiboDn", 11, "(-176.4%) -  %$");
   ObjectSet("FiboDn", 222, 2.0);
   ObjectSetFiboDescription("FiboDn", 12, "(-200.0%) -  %$");
   ObjectSet("FiboDn", 223, 2.5);
   ObjectSetFiboDescription("FiboDn", 13, "(-250.0%) -  %$");
   ObjectSet("FiboDn", 224, 3.0);
   ObjectSetFiboDescription("FiboDn", 14, "(-300.0%) -  %$");
   ObjectSet("FiboDn", 225, 3.5);
   ObjectSetFiboDescription("FiboDn", 15, "(-350.0%) -  %$");
   ObjectSet("FiboDn", 226, 4.0);
   ObjectSetFiboDescription("FiboDn", 16, "(-400.0%) -  %$");
   ObjectSet("FiboDn", 227, 4.5);
   ObjectSetFiboDescription("FiboDn", 17, "(-450.0%) -  %$");
   ObjectSet("FiboDn", 228, 5.0);
   ObjectSetFiboDescription("FiboDn", 18, "(-500.0%) -  %$");
   ObjectSet("FiboDn", OBJPROP_RAY, TRUE);
   ObjectSet("FiboDn", OBJPROP_BACK, TRUE);
   if (Gi_440) {
      if (ObjectFind("FiboIn") == -1) ObjectCreate("FiboIn", OBJ_FIBO, 0, G_datetime_468, G_ihigh_444, G_datetime_468 + 86400, G_ilow_452);
      else {
         ObjectSet("FiboIn", OBJPROP_TIME2, G_datetime_468);
         ObjectSet("FiboIn", OBJPROP_TIME1, G_datetime_468 + 86400);
         ObjectSet("FiboIn", OBJPROP_PRICE1, G_ihigh_444);
         ObjectSet("FiboIn", OBJPROP_PRICE2, G_ilow_452);
      }
      ObjectSet("FiboIn", OBJPROP_LEVELCOLOR, G_color_432);
      ObjectSet("FiboIn", OBJPROP_FIBOLEVELS, 7);
      ObjectSet("FiboIn", OBJPROP_FIRSTLEVEL, 0.0);
      ObjectSetFiboDescription("FiboIn", 0, "Daily LOW (0.0) -  %$");
      ObjectSet("FiboIn", 211, 0.236);
      ObjectSetFiboDescription("FiboIn", 1, "(23.6) -  %$");
      ObjectSet("FiboIn", 212, 0.382);
      ObjectSetFiboDescription("FiboIn", 2, "(38.2) -  %$");
      ObjectSet("FiboIn", 213, 0.5);
      ObjectSetFiboDescription("FiboIn", 3, "(50.0) -  %$");
      ObjectSet("FiboIn", 214, 0.618);
      ObjectSetFiboDescription("FiboIn", 4, "(61.8) -  %$");
      ObjectSet("FiboIn", 215, 0.764);
      ObjectSetFiboDescription("FiboIn", 5, "(76.4) -  %$");
      ObjectSet("FiboIn", 216, 1.0);
      ObjectSetFiboDescription("FiboIn", 6, "Daily HIGH (100.0) -  %$");
      ObjectSet("FiboIn", OBJPROP_RAY, TRUE);
      ObjectSet("FiboIn", OBJPROP_BACK, TRUE);
   } else ObjectDelete("FiboIn");
   return (0);
}

string IIFs(bool condition, string ifTrue, string ifFalse) {
 
  if (condition) return(ifTrue); else return(ifFalse);
}

void RapidTrailingStop() {

   double l_point_36;
   double ld_44;
   double ld_52;
   double ld_60;
   double ld_68;   
   
   bool result;
   for (int l_pos_100 = 0; l_pos_100 < OrdersTotal(); l_pos_100++) {
      
      if(OrderSelect(l_pos_100, SELECT_BY_POS, MODE_TRADES)== false) break;
      if (OrderSymbol() == Symbol() ) {
         if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.00001) l_point_36 = 0.0001;
         else {
            if (MarketInfo(OrderSymbol(), MODE_POINT) == 0.001) l_point_36 = 0.01;
            else l_point_36 = MarketInfo(OrderSymbol(), MODE_POINT);
         }
         ld_52 = Start_Trailing_At * l_point_36;   /// 20 PIPS 
         ld_44 = TrailingStep * l_point_36;        /// 5 PIPS

         ld_68 = Set_BreakEvenAt * l_point_36;
         ld_60 = LockPips * l_point_36;
         
         
         if (OrderType() == OP_BUY && (OrderMagicNumber() == MagicNumber)) {
            if (Use_TrailingStep && Bid - OrderOpenPrice() >= ld_52) {
             //if(EASymbol=="GBPUSD")Print("Bid - OrderStopLoss() >= ld_52 + ld_44 =", " ", Bid, " ",OrderStopLoss(), " ",   ld_52 ,"    ", ld_44);
               if (Bid - OrderStopLoss() >= ld_52 + ld_44) {
                  //Print("Hello !");
                  result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss() + ld_44, OrderTakeProfit(), 0, DodgerBlue);
                  if ( GetLastError()!=0) Print(Symbol()+ ": Trail BUY OrderModify PROBLEM ! " );   
               }
            }

            if (Use_Set_BreakEven && Bid - OrderOpenPrice() >= ld_68) {
               if (OrderStopLoss() < OrderOpenPrice()) {
                  result= OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + ld_60, OrderTakeProfit(),0, DodgerBlue);
                  if ( GetLastError()!=0) Print(Symbol()+ ": BreakEven BUY OrderModify PROBLEM ! " );   

               }
            }
            
            
         } else {
            if (OrderType() == OP_SELL && (OrderMagicNumber() == MagicNumber)) {
               if (Use_TrailingStep && OrderOpenPrice() - Ask >= ld_52) {
                 // if(EASymbol=="AUDUSD")Print("OrderStopLoss() - Ask >= ld_52 + ld_44", " ",OrderStopLoss(), " ", Ask," ",  ld_52 ," ", ld_44);
                  if (OrderStopLoss() - Ask >= ld_52 + ld_44) {
                   //Print ("Hello !!");
                   result= OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss() - ld_44, OrderTakeProfit(),0, Yellow);
                   if (GetLastError()!=0) Print(Symbol()+ ": Trail SELL OrderModify PROBLEM ! " );
                  }
               }
              
               if (Use_Set_BreakEven && OrderOpenPrice() - Ask >= ld_68) {
                  if (OrderStopLoss() > OrderOpenPrice()) {
                     result= OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - ld_60, OrderTakeProfit(),0, Yellow);
                    if ( GetLastError()!=0) Print(Symbol()+ ": BreakEven SELL OrderModify PROBLEM ! " );   

                  }
               }
            }
         }
      }
   }
}










/*
void RapidManager(double &pDistance, double &pLimit, double &pStopLoss, int Position) {
   	//pFilter = NoTrade_Profit_Yet_Filter;
   	//pStopLoss = NoTrade_Profit_Yet_StopLoss;
   	pDistance = NoTrade_Profit_Yet_Distance; 	
   	pLimit = NoTrade_Profit_Yet_Limit;
   	pStopLoss= NoTrade_Profit_Yet_StopLoss;

   if (OrderSymbol() == Symbol() && OrderCount() >=1 ) 
   	Print(Symbol(),   "getProfit = ", getProfit(Position), "  position= ", Position);



   if (OrderSymbol() == Symbol()&& getProfit(Position) >= 2 && OrderCount() >=1 ) {
   	Print(Symbol(),   "getProfit = ", getProfit(Position), "  position= ", Position);

   	//pFilter = InTrade_Profit_Filter;
   	//pStopLoss = InTrade_Profit_StopLoss;
   	pDistance = InTrade_Profit_Distance; 
   	pLimit = InTrade_Profit_Limit;
   	pStopLoss= InTrade_Profit_StopLoss;
  }
}
	
	
int getProfit() {

  //int last_closed_order_ticket=0;
  //sLatest_Time = 0;
  int Latest_Profit = 0;
  for(int pos=OrdersTotal(); pos >= 0; pos--) {
  
    if ( OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)// Only orders w/
        &&  OrderMagicNumber()  == MagicNumber          // my order comment
        &&  OrderType()         <= OP_SELL)        {  
        //Print(" Last Order Ticket = ",OrderTicket());
        //Print(" Last Order Ticket closed time = ",OrderCloseTime());
         //sLatest_Time =  OrderOpenTime();
         Latest_Profit += OrderProfit()+OrderCommission()+OrderSwap();
         break;
      }
     }
    Print("Latest profit=", Latest_Profit); 
    return(Latest_Profit); 
 }*/	
 
 
 
	//   for (pos_108 = 0; pos_108 < OrdersTotal(); pos_108++) {
   //   if (OrderSelect(pos_108, SELECT_BY_POS, MODE_TRADES)) {
/*	
double getProfit(int Position) {
	int D_Factor = 1;
	if(Digits == 3||Digits == 5) D_Factor = 10;
   int total = OrdersTotal();
   //for (int i = total - 1; i >= 0; i--) {
   for (int i = 0; i < OrdersTotal(); i++) {
     if (OrderSelect(Position, SELECT_BY_POS) == TRUE) {
         if (/*OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY){ return ((Bid - OrderOpenPrice()) / Point/D_Factor); break;}
         if (/*OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL){ return ((OrderOpenPrice() - Ask) / Point/D_Factor); break;}
    }
   } 
    return(0);
}	



int getProfit()
{
  int D_Factor = 1;
  double Profit_Pips;
//----
   if(Digits == 3||Digits == 5)D_Factor = 10;
   for(int i=0;i<OrdersTotal();i++){
       if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
          if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Profit_Pips = (MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice())/Point/D_Factor;
          if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) Profit_Pips = (OrderOpenPrice() - MarketInfo(OrderSymbol(),MODE_ASK))/Point/D_Factor;
           //Print("Order No : " + OrderTicket() + " Profit = " + DoubleToStr(Profit_Pips,1));
       }
         else{
         Print("Access to trades failed with error (",GetLastError(),")");
         break;
         }
      }
//----
   return(0);
}


int OrderCount(){                       // we counting our order here
   int total=0;                         // total of our order 
   int i;                               // pos of our order 
   for(i=0; i<OrdersTotal(); i++) {     // looping to count our order 
                                        // from pos 0 until last pos
   
       OrderSelect(i,SELECT_BY_POS,MODE_TRADES);  // is it right our order?
       if(OrderSymbol()!=Symbol() ||    // if symbol of order didn't match 
       OrderMagicNumber()!=MagicNumber) // with current chart symbol 
       continue;                        // or the magic numb of order 
                                        // didn't match with our magic
                                        // number, don't count it
       total++;                         // count if all criteria matched
   }
   return(total);                       // this function returned total of
                                        // our opened order 
}
*/