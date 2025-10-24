import java.util.HashMap;
import java.util.ArrayList;

int cols = 7, rows = 6;
int canvasWidth, canvasHeight;
int cellWidth, cellHeight;
int startDay = 5, numDays = 28;
int selectedDay = -1;
String[] weekdays = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"};

HashMap<Integer, ArrayList<String>> dayToEvents = new HashMap<>();

int    popupDay = -1;
float  popupX = 300, popupY = 200, popupW = 350, popupH;
boolean draggingPopup = false;
float  dragOffsetX, dragOffsetY;

PFont fontRegular, fontBold;

// Multi-day spans
int bdLoserStart   = 1, bdLoserEnd   = 13;
int steveJobsStart = 16, steveJobsEnd = 33;
int theWayStart    = 12, theWayEnd    = 27;
int diaryCEO       = 22, theoVon      = 23;

// Colours 
color headerPurple = color(42, 42, 87);
color cellBg       = color(41, 43, 42);

// Darker shades for events
color eventBlue    = color(70, 130, 180);   // dark steel blue
color eventRed     = color(180,   0,   0);   // deep red
color eventGrey    = color(100, 100, 100);   // mid grey
color eventBlack   = color(0);               // black for CEO
color eventPink    = color(219,112,147);     // deep pink

class BookInfo {
  String title, author, medium, genre;
  BookInfo(String t, String a, String m, String g) {
    title  = t; author = a; medium = m; genre = g;
  }
}
HashMap<String,BookInfo> infoMap = new HashMap<>();

String trimSpaces(String s) {
  return s != null ? s.trim() : null;
}

void setup() {
  size(1000, 900);
  cellWidth  = width  / cols;
  cellHeight = (height - 100) / rows;
  textAlign(LEFT, TOP);

  fontRegular = createFont("Helvetica",     14);
  fontBold    = createFont("Helvetica-Bold",32);

  // load metadata
  Table meta = loadTable("book_data.csv", "header");
  for (TableRow row : meta.rows()) {
    String t = trimSpaces(row.getString("title"));
    String a = trimSpaces(row.getString("author"));
    String m = trimSpaces(row.getString("medium"));
    String g = trimSpaces(row.getString("genre"));
    infoMap.put(t, new BookInfo(t, a, m, g));
  }

  // populate events
  addEventToDay("Billion Dollar Loser", bdLoserStart);
  addEventToDay("Billion Dollar Loser", bdLoserEnd);
  addEventToDay("The Way of Kings", theWayStart, theWayEnd);
  addEventToDay("Steve Jobs", steveJobsStart, steveJobsEnd);
  addEventToDay("Diary of a CEO", diaryCEO);
  addEventToDay("Theo Von Podcast", theoVon);
}

void draw() {
  background(headerPurple);
  drawCalendarHeader();
  drawWeekdayLabels();
  drawCalendarGrid();

  // use darker event colours
  drawMultiDayEvent(theWayStart, theWayEnd,       eventRed,   "The Way of Kings",     2);
  drawMultiDayEvent(bdLoserStart, bdLoserEnd,     eventBlue,  "Billion Dollar Loser", 1, true);
  drawMultiDayEvent(steveJobsStart, steveJobsEnd, eventGrey,  "Steve Jobs",           3);

  drawSingleDayEvent(diaryCEO, eventBlack, "Diary of a CEO",   1);
  drawSingleDayEvent(theoVon,  eventPink,  "Theo Von Podcast", 1);

  if (popupDay != -1) {
    drawPopup(popupDay);
  }
}

void drawCalendarHeader() {
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(fontBold);
  textSize(32);
  text("February 2025", width/2, 30);
  textAlign(LEFT, TOP);
}

void drawWeekdayLabels() {
  fill(180);
  textFont(fontRegular);
  textAlign(CENTER, CENTER);
  textSize(18);
  for (int i = 0; i < weekdays.length; i++) {
    text(weekdays[i], i * cellWidth + cellWidth/2, 70);
  }
  textAlign(LEFT, TOP);
}

void drawCalendarGrid() {
  stroke(80);
  fill(255);
  textFont(fontRegular);
  textSize(18);
  int dayCounter = 1;
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      int x = col * cellWidth;
      int y = row * cellHeight + 100;
      int idx = row * cols + col;
      if (row == 5) {
        fill(headerPurple);
      } 
      else if (idx >= startDay && dayCounter <= numDays) {
        fill(dayCounter == selectedDay ? color(255,100,100) : cellBg);
        rect(x, y, cellWidth, cellHeight);
        fill(255);
        text(dayCounter, x + 8, y + 8);
        dayCounter++;
      } 
      else {
        fill(20);
        rect(x, y, cellWidth, cellHeight);
      }
    }
  }
}

void drawMultiDayEvent(int s, int e, color c, String label, int off) {
  drawMultiDayEvent(s, e, c, label, off, false);
}
void drawMultiDayEvent(int s, int e, color c, String label, int off, boolean full) {
  for (int d = s; d <= e; d++) {
    if (d < 1 || d > numDays) continue;
    int col = (d + startDay - 1) % cols;
    int row = (d + startDay - 1) / cols;
    float x = col * cellWidth, y = row * cellHeight + 100;
    float y0 = y + cellHeight/2 - 24 + off * 22;
    noStroke();
    fill(c);
    rect(x+4, y0, cellWidth-8, 20, 6);
    if (d == s) {
      fill(255);
      textFont(fontRegular);
      textSize(14);
      if (full) {
        text(label, x+10, y0+2, (e - s + 1)*cellWidth - 20, 20);
      } else {
        text(label, x+10, y0+2);
      }
    }
  }
}

void drawSingleDayEvent(int day, color c, String label, int off) {
  if (day < 1 || day > numDays) return;
  int col = (day + startDay - 1) % cols;
  int row = (day + startDay - 1) / cols;
  float x = col * cellWidth, y = row * cellHeight + 100;
  float y0 = y + cellHeight/2 - 24 + off * 22;
  noStroke();
  fill(c);
  rect(x+4, y0, cellWidth-8, 20, 6);
  fill(255);
  textFont(fontRegular);
  textSize(14);
  text(label, x+10, y0+2);
}

void drawPopup(int day) {
  ArrayList<String> titles = dayToEvents.get(day);
  int   lines = 4;
  float hLine = 16;
  float block = lines * hLine + 10;
  popupH = 60 + titles.size() * block;

  noStroke();
  fill(255);
  rect(popupX, popupY, popupW, popupH, 10);
  stroke(0);
  noFill();
  rect(popupX, popupY, popupW, popupH, 10);

  fill(0);
  textAlign(CENTER, TOP);
  textFont(fontRegular);
  textSize(18);
  text("Events on Feb " + day, popupX + popupW/2, popupY + 15);

  textAlign(LEFT, TOP);
  textSize(14);
  fill(0);
  for (int i = 0; i < titles.size(); i++) {
    BookInfo bi = infoMap.get(titles.get(i));
    float y0 = popupY + 45 + i * block;
    if (bi != null) {
      text("- " + bi.title,             popupX + 15, y0);
      text("    Author: " + bi.author, popupX + 15, y0 + hLine);
      text("    Medium: " + bi.medium, popupX + 15, y0 + 2*hLine);
      text("    Genre: "  + bi.genre,  popupX + 15, y0 + 3*hLine);
    } else {
      text("- " + titles.get(i), popupX + 15, y0);
    }
  }

  fill(200, 50, 50);
  noStroke();
  rect(popupX + popupW - 25, popupY + 10, 15, 15, 3);
  fill(255);
  textAlign(CENTER, CENTER);
  text("X", popupX + popupW - 17.5, popupY + 17.5);
}

void addEventToDay(String title, int day) {
  dayToEvents.computeIfAbsent(day, k -> new ArrayList<String>()).add(title);
}
void addEventToDay(String title, int start, int end) {
  for (int d = start; d <= end; d++) {
    addEventToDay(title, d);
  }
}

void mousePressed() {
  if (popupDay != -1) {
    if (mouseX > popupX + popupW - 25 && mouseX < popupX + popupW - 10 &&
        mouseY > popupY + 10        && mouseY < popupY + 25) {
      popupDay = -1;
      return;
    }
    if (mouseX > popupX && mouseX < popupX + popupW &&
        mouseY > popupY && mouseY < popupY + 30) {
      draggingPopup = true;
      dragOffsetX   = mouseX - popupX;
      dragOffsetY   = mouseY - popupY;
      return;
    }
  }
  int col = mouseX / cellWidth;
  int row = (mouseY - 100) / cellHeight;
  int idx = row * cols + col;
  int day = idx - startDay + 1;
  if (day >= 1 && day <= numDays) {
    selectedDay = day;
    popupDay    = dayToEvents.containsKey(day) ? day : -1;
  } else {
    selectedDay = popupDay = -1;
  }
}

void mouseDragged() {
  if (draggingPopup) {
    popupX = mouseX - dragOffsetX;
    popupY = mouseY - dragOffsetY;
  }
}

void mouseReleased() {
  draggingPopup = false;
}
