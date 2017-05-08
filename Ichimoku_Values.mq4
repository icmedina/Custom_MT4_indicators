//+------------------------------------------------------------------+
//|                                      Ichimoku Kinko Hyo Values   |
//|                                           Tenkan-sen, Kijun-sen, |
//|                                    Senkou Span A, Senkou Span A  |
//|                   values for Support and Resistance or Stop-loss | 
//|                                                      Dec. 2016   |
//+------------------------------------------------------------------+

#property copyright "Dec 2016"
#property link      ""
#property indicator_chart_window
//---- indicator parameters
extern string Indicator_Settings = "************";
extern int Tenkan_Sen = 9;
extern int Kijun_Sen = 26;
extern int Senkou_Span_B = 52;
extern int shift = 0;
extern double price_adjustment = 0.005;
//----- parameters for values of bands
extern string Text_options = "*** Values Settings ***";
extern color  TextColor = LightCyan;
extern string FontType  = "Arial";
extern int    FontSize  = 8;
extern int    Window  = 0;
extern string Position = "*** Position Settings: ***";
extern string Anchor_options1 = "1: Top-right; 2: Bottom-left";
extern string Anchor_options2 = "3: Bottom-right; 4: Top-left";
extern int    Anchor = 1; 
extern int    x_Distance = 11;
extern int    y_Distance = 0;

string trend_direction, trend_strength, bullish_strength, bearish_strength;
int bullish_price_action, bullish_tkcross, bullish_future_cloud;
int bearish_price_action, bearish_tkcross, bearish_future_cloud;

double price, tenkan_sen, kijun_sen, senkou_span_a, senkou_span_b, chikouspan;
double senkou_span_a_future, senkou_span_b_future;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
//----
  ObjectDelete("_price");
  ObjectDelete("_trend_direction");
  ObjectDelete("_trend_strength");
  ObjectDelete("_tenkan_sen");
  ObjectDelete("_kijun_sen");
  ObjectDelete("_senkou_span_a");
  ObjectDelete("_senkou_span_b");
  //----
  return(0);
}
 
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo                                                  |
//+------------------------------------------------------------------+
int start()
  {
//-- settings of values shown for separator
  ObjectCreate("_price",OBJ_LABEL,Window,Time[0],Close[0]);
  ObjectSet("_price",OBJPROP_CORNER,Anchor);
  ObjectSet("_price",OBJPROP_XDISTANCE,x_Distance);
  ObjectSet("_price",OBJPROP_YDISTANCE,y_Distance + 38);

//-- settings of values shown for tenkan_sen
  ObjectCreate("_tenkan_sen",OBJ_LABEL,Window,Time[0],Close[0]);
  ObjectSet("_tenkan_sen",OBJPROP_CORNER,Anchor);
  ObjectSet("_tenkan_sen",OBJPROP_XDISTANCE,x_Distance);
  ObjectSet("_tenkan_sen",OBJPROP_YDISTANCE,y_Distance + 52);

//-- settings of values shown for kijun_sen
  ObjectCreate("_kijun_sen",OBJ_LABEL,Window,Time[0],Close[0]);
  ObjectSet("_kijun_sen",OBJPROP_CORNER,Anchor);
  ObjectSet("_kijun_sen",OBJPROP_XDISTANCE,x_Distance);
  ObjectSet("_kijun_sen",OBJPROP_YDISTANCE,y_Distance + 66);

//-- settings of values shown for senkou_span_a
  ObjectCreate("_senkou_span_a",OBJ_LABEL,Window,Time[0],Close[0]);
  ObjectSet("_senkou_span_a",OBJPROP_CORNER,Anchor);
  ObjectSet("_senkou_span_a",OBJPROP_XDISTANCE,x_Distance);
  ObjectSet("_senkou_span_a",OBJPROP_YDISTANCE,y_Distance + 80);

//-- settings of values shown for senkou_span_b
  ObjectCreate("_senkou_span_b",OBJ_LABEL,Window,Time[0],Close[0]);
  ObjectSet("_senkou_span_b",OBJPROP_CORNER,Anchor);
  ObjectSet("_senkou_span_b",OBJPROP_XDISTANCE,x_Distance);
  ObjectSet("_senkou_span_b",OBJPROP_YDISTANCE,y_Distance + 94);

//-- settings of values shown for trend_direction
  ObjectCreate("_trend_direction",OBJ_LABEL,Window,Time[0],Close[0]);
  ObjectSet("_trend_direction",OBJPROP_CORNER,Anchor);
  ObjectSet("_trend_direction",OBJPROP_XDISTANCE,x_Distance);
  ObjectSet("_trend_direction",OBJPROP_YDISTANCE,y_Distance + 10);

   
//-- Get the actual values from the indicator  
  tenkan_sen = iIchimoku(NULL, 0, Tenkan_Sen, Kijun_Sen, Senkou_Span_B, MODE_TENKANSEN, shift);
  kijun_sen = iIchimoku(NULL, 0, Tenkan_Sen, Kijun_Sen, Senkou_Span_B, MODE_KIJUNSEN, shift);
  senkou_span_a = iIchimoku(NULL, 0, Tenkan_Sen, Kijun_Sen, Senkou_Span_B, MODE_SENKOUSPANA, shift); // current senkou span a
  senkou_span_b = iIchimoku(NULL, 0, Tenkan_Sen, Kijun_Sen, Senkou_Span_B, MODE_SENKOUSPANB, shift); // current senkou span b
  chikouspan = iIchimoku(NULL, 0, Tenkan_Sen, Kijun_Sen, Senkou_Span_B, MODE_CHIKOUSPAN, shift);  //  a 26 days pushed back
  
  senkou_span_a_future = iIchimoku(NULL, 0, Tenkan_Sen, Kijun_Sen, Senkou_Span_B, MODE_SENKOUSPANA, shift-26); // senkou span a 26 days ahead 
  senkou_span_b_future = iIchimoku(NULL, 0, Tenkan_Sen, Kijun_Sen, Senkou_Span_B, MODE_SENKOUSPANB, shift-26); // senkou span b 26 days ahead

//-- Get current market price
   price = (double)MarketInfo(NULL,MODE_BID);    
   price = price + price_adjustment; // Adjustment for (USDJP easyMarkets)

//-- Determine trend according to values of senkou span a & b
  if (((price <= senkou_span_a) && (price > senkou_span_b)) || ((price >= senkou_span_a) && (price < senkou_span_b)))  {
    trend_direction = "Ranging"; } // price is within the cloud

//-- Calculation of Bullish Strength    
  if ((price > senkou_span_a) || (price > senkou_span_b)){ // price is above the cloud (bullish)
     trend_direction = "Bullish";
     bullish_price_action = 1; 
   }     
  if (tenkan_sen > kijun_sen){      // bullish TK cross
    bullish_tkcross = 1;
  }
  if (senkou_span_a_future > senkou_span_b_future){ // bullish future
    bullish_future_cloud = 1;
  }
  // Calculate the bullish strength
  bullish_strength = bullish_price_action + bullish_tkcross + bullish_future_cloud;
//--

//-- Calculation of Bearish Strength    
  if ((price < senkou_span_a) || (price < senkou_span_b)){ // price is below the cloud (bearish)  
     trend_direction = "Bearish";
     bearish_price_action = 1; 
   }     
  if (tenkan_sen < kijun_sen){      // bearish TK cross
    bearish_tkcross = 1;
  }
  if (senkou_span_a_future < senkou_span_b_future){ // bearish future
    bearish_future_cloud = 1;
  }
  // Calculate the bearish strength
  bearish_strength = bearish_price_action + bearish_tkcross + bearish_future_cloud;
//--    
    
  if (trend_direction =="Bullish"){
   trend_strength = bullish_strength;}
  if (trend_direction =="Bearish"){
   trend_strength = bearish_strength;}
   
//-- 
  ObjectSetText("_price","Price: "+DoubleToStr(price,Digits),FontSize,FontType,TextColor);
  ObjectSetText("_tenkan_sen","Tenkan-sen: "+DoubleToStr(tenkan_sen,Digits),FontSize,FontType,TextColor);
  ObjectSetText("_kijun_sen","Kijun-sen: "+DoubleToStr(kijun_sen,Digits),FontSize,FontType,TextColor);   
  ObjectSetText("_senkou_span_a","Senkou Span A: "+DoubleToStr(senkou_span_a,Digits),FontSize,FontType,TextColor);   
  ObjectSetText("_senkou_span_b","Senkou Span B: "+DoubleToStr(senkou_span_b,Digits),FontSize,FontType,TextColor);   
  ObjectSetText("_trend_direction","Trend: "+ trend_direction,10,FontType,TextColor);  
  
  if ((trend_direction == "Bullish") || (trend_direction == "Bearish")){ // Strength is shown only if trending, hidden if ranging
//-- settings of values shown for trend_strength
  ObjectCreate("_trend_strength",OBJ_LABEL,Window,Time[0],Close[0]);
  ObjectSet("_trend_strength",OBJPROP_CORNER,Anchor);
  ObjectSet("_trend_strength",OBJPROP_XDISTANCE,x_Distance);
  ObjectSet("_trend_strength",OBJPROP_YDISTANCE,y_Distance + 24);
  ObjectSetText("_trend_strength","Strength: "+ trend_strength ,10,FontType,TextColor);  
  }
//----
   return(0);
  }
//+------------------------------------------------------------------+