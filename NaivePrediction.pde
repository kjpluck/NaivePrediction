import com.hamoid.*;
VideoExport videoExport;

FloatDict data = new FloatDict();

float seaIceArea19April = 0;
void setup()
{
  size(1000,1000);
  verticalScale = height/18.0;
  loadData();
  background(0);
  strokeWeight(3);
  
  seaIceArea19April = data.get("2019-04-19");
  
    videoExport = new VideoExport(this);
    videoExport.setFrameRate(60);
    videoExport.startMovie();
}

int startSlideYear = 2050;
float verticalScale;
  
float lastX = 0;
float lastY = 0;
float lastOriginalY = 0;

void draw()
{
  background(25, 41, 64);
  drawAxis();
  stroke(255,255,0);
  int maxYear = frameCount + 1978;
  
  float diffLerp = 0;
  
  if(maxYear > startSlideYear)
  {
    diffLerp = ease((maxYear - startSlideYear) * 1.0/360.0);
    drawLines(maxYear, 0, color(30, 46, 69), true);
  }
  if(diffLerp > 1)
    diffLerp = 1;
  
  drawLines(maxYear, diffLerp, color(255,255,0), false);
  
  videoExport.saveFrame();
  
  if(frameCount > 700)
  {
    videoExport.endMovie();
    exit();
  }
}

float ease(float lerp)
{
  if(lerp > 1) lerp = 1;
  if(lerp < 0) lerp = 0;
  return 1.0- (cos(lerp * PI) + 1.0) / 2.0 ;
}

void drawLines(int maxYear, float diffLerp, color colour, boolean shadow)
{
  pushStyle();
  
  for(int year = 1979; year < maxYear; year++)
  {
    if(year > 2019)
      continue;
      
    
  
    if(shadow)
      stroke(colour);
    else
    {
      float colourLerp = (float(year)-1979.0) / 40.0;
      if(colourLerp > 1) colourLerp = 1;
      if(colourLerp < 0) colourLerp = 0;
      
      color newColour = color(red(colour) * colourLerp, green(colour) * colourLerp, blue(colour) * colourLerp );
      stroke(newColour);
    }
    
    if(year == 2019)
      stroke(255,0,0);
    
    float seaIceAreaOfTheCurrentYearOnThe19thOfApril = data.get(year + "-04-19");
    float diff = seaIceAreaOfTheCurrentYearOnThe19thOfApril - seaIceArea19April;
    
    diff = diff * diffLerp;
      
    lastX=0;
    lastY=0;
    lastOriginalY = 0.0;
    
    for(int yearDay = 1; yearDay<=365; yearDay++)
    {
      
      String theDate = makeDate(year, yearDay);
      
      if(!data.hasKey(theDate))
        continue;
      
      float seaIceArea = data.get(theDate);
      
      float x = yearDay * (width/365.0);
      
      float y = 0.0;
      float originalY = 0.0;
      if(yearDay >= 109)
      {
        originalY = height - (seaIceArea * verticalScale);
        y = height - ((seaIceArea - diff) * verticalScale);
      }
      else
        y = height - (seaIceArea * verticalScale);
        
      if(yearDay == 109 && maxYear > startSlideYear)
      {
        lastX=0;
        lastY=0;
      }
      
      if(lastX == 0)
      {
        lastX = x;
        lastY = y;
        lastOriginalY = originalY;
      }
      
      
      line(lastX, lastY, x, y);
      
      lastX = x;
      lastY = y;
      lastOriginalY = originalY;
    }
  }
  popStyle();
}

void loadData()
{
  String[] file = loadStrings("nsidc_NH_SH_nt_final_and_nrt.txt");
  for(String line: file)
  {
    if(line.startsWith("#"))
      continue;
    if(line.startsWith(" "))
      continue;
    
    String[] values = line.split(",");
    String date = values[0].split(" ")[0];
    float area = parseFloat(values[2]);
    
    data.add(date, area);
  }
}

public static DateTime GetNonLeapYear()
{
  return new DateTime(2001,1,1,0,0,0,0);
}

void drawAxis()
{
  textSize(50);
  
  pushStyle();
    noStroke();
    fill(35,51,74);
    textAlign(RIGHT);
    for(int area=0; area < 20; area+=2)
    {
      rect(0,height - area*verticalScale,width,verticalScale);
      
      text(area, 100, (height - area * verticalScale) - 8);
    }
    
    textAlign(LEFT);
    text("million km²", 110, (height - 6 * verticalScale) - 8);
  popStyle();
  
  String[] months = {"J","F","M","A","M","J","J","A","S","O","N","D"};
  pushStyle();
    textAlign(CENTER);
    fill(25, 41, 64);
    float mScale = width / 12.0;
    for(int m=0; m<12; m++)
    {
      text(months[m], 45 + m * mScale, (height - 1 * verticalScale) - 10);
    }
  popStyle();
  
  pushStyle();
    textAlign(RIGHT);
    fill(255);
    text("Arctic Sea Ice Extent", width - 20, (height - 16 * verticalScale) - 8);
    textSize(20);
    textLeading(27);
    text("Previous paths from current record low extent\nData: NSIDC\n@KevPluck PixelMoversAndMakers.com", width - 20, (height - 15 * verticalScale) - 6);
  popStyle();
}

String makeDate(int year, int yearDay)
{
  
    DateTime date = GetNonLeapYear().withDayOfYear(yearDay);
    
    int month = date.get(DateTimeFieldType.monthOfYear());
    String monthZeroPad = String.format("%02d", month);
    int day = date.get(DateTimeFieldType.dayOfMonth());
    String dayZeroPad = String.format("%02d", day);
    
    return year+"-"+monthZeroPad+"-"+dayZeroPad;
}
