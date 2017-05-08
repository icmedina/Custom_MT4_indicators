//+------------------------------------------------------------------+
//|                                                        Bands.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                     modified by: Ice
//| customizations: shows the value of the upper and lower band and
//| allows the user to change the color or the middle band
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DarkOrange // default: LightSeaGreen
#property indicator_color2 LightSeaGreen
#property indicator_color3 LightSeaGreen
#property indicator_width1 2           // thickness of the middle band (20 period MA) default: 1 

//---- indicator parameters
extern int    BandsPeriod=20;
extern int    BandsShift=0;
extern double BandsDeviation=2.0;
extern string price_options1 = "0: Close; 1: High;2: Low; 3: Median (HL/2)";
extern string price_options2 = "4: Open; 5: Typical (HLC/3);6: Weighted (HLCC/4)";
extern int    BandsAppliedPrice = 0;
extern int    CandleShift       = 0;

//----- parameters for values of bands
extern string Text_options = "*** Shown Values Settings ***";;
extern color  TextColor = LightCyan;
extern string FontType  = "Arial";
extern int    FontSize  = 8;
extern int    xDistance = 11;

//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];

double upperBand,lowerBand;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MovingBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,UpperBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,LowerBuffer);
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
//----
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
//----
  ObjectDelete("_upperBBline");
  ObjectDelete("_lowerBBline");
//----
  return(0);
}
  
  
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int start()
  {
  
   int    i,k,counted_bars=IndicatorCounted();
   double deviation;
   double sum,oldval,newres;
//----
   if(Bars<=BandsPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=BandsPeriod;i++)
        {
         MovingBuffer[Bars-i]=EMPTY_VALUE;
         UpperBuffer[Bars-i]=EMPTY_VALUE;
         LowerBuffer[Bars-i]=EMPTY_VALUE;
        }
//----
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
   for(i=0; i<limit; i++)
      MovingBuffer[i]=iMA(NULL,0,BandsPeriod,BandsShift,MODE_SMA,BandsAppliedPrice,i);
//----
   i=Bars-BandsPeriod+1;
   if(counted_bars>BandsPeriod-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      sum=0.0;
      k=i+BandsPeriod-1;
      oldval=MovingBuffer[i];
      while(k>=i)
        {
         newres=Close[k]-oldval;
         sum+=newres*newres;
         k--;
        }
      deviation=BandsDeviation*MathSqrt(sum/BandsPeriod);
      UpperBuffer[i]=oldval+deviation;
      LowerBuffer[i]=oldval-deviation;
      i--;
     }
//-- values shown for for upper and lower bands
  ObjectDelete("_upperBBline");
  ObjectDelete("_lowerBBline");

  ObjectCreate("_upperBBline",OBJ_LABEL,0,Time[0],Close[0]);
  ObjectSet("_upperBBline",OBJPROP_CORNER,1);
  ObjectSet("_upperBBline",OBJPROP_XDISTANCE,xDistance);
  ObjectSet("_upperBBline",OBJPROP_YDISTANCE,10);
  ObjectSetText("_upperBBline"," ",FontSize,FontType,TextColor);
  //
  ObjectCreate("_lowerBBline",OBJ_LABEL,0,Time[0],Close[0]);
  ObjectSet("_lowerBBline",OBJPROP_CORNER,1);
  ObjectSet("_lowerBBline",OBJPROP_XDISTANCE,xDistance);
  ObjectSet("_lowerBBline",OBJPROP_YDISTANCE,24);
  ObjectSetText("_lowerBBline"," ",FontSize,FontType,TextColor);
  //
  upperBand = iCustom(NULL,0,"Bands",BandsPeriod,BandsShift,BandsDeviation,1,CandleShift);//old, without iCustom and without double-var for deviation: iBands(NULL,0,BandsPeriod,BandsDeviation,BandsShift,BandsAppliedPrice,MODE_UPPER,CandleShift);
  lowerBand = iCustom(NULL,0,"Bands",BandsPeriod,BandsShift,BandsDeviation,2,CandleShift);//old, without iCustom and without double-var for deviation: iBands(NULL,0,BandsPeriod,BandsDeviation,BandsShift,BandsAppliedPrice,MODE_LOWER,CandleShift);
  //
  ObjectSetText("_upperBBline","Upper: "+DoubleToStr(upperBand,Digits),FontSize,FontType,TextColor);
  ObjectSetText("_lowerBBline","Lower: "+DoubleToStr(lowerBand,Digits),FontSize,FontType,TextColor);   
//----
     
   return(0);
  }
//+------------------------------------------------------------------+