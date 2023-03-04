abstract class Scene {
//the Scene class is kind of a wrapper around Processing's builtin functions, to make it easy to switch program behavior on the fly, e.g. between menus and gameplay
    protected Scene changeScene;
    //public abstract void setup();
    public abstract void draw();
//The default events are hard to use, so I made it a bit easier
    public abstract void keyEvent(int keyValue, boolean pressed);
    public abstract void mouseEvent(int x, int y, boolean pressed);
//check if the scene is ready to change, if so then getNewScene is expected
    public boolean sceneChanged() {
        return changeScene != null;
    }
    public Scene getNewScene() {
        return changeScene;
    }
}
class MainMenu extends Scene {
    public MainMenu() {
    }
    public void draw() {
        background(0,0,0);
        fill(255, 255, 255);
        textAlign(CENTER);
        textSize(uiScale/10);
        text("MINESWEEPER!", width/2, height/4);
        textSize(uiScale/20);
        text("Press enter or click anywhere to continue", width/2, height/2);
    }
    public void keyEvent(int keyValue, boolean pressed) {
        if (!pressed && keyValue == ENTER) changeScene = new MinesSelector();//new MinesGame(10, 10, (int)(10*10*.2));
    }
    public void mouseEvent(int x, int y, boolean pressed) {
        if (!pressed) changeScene = new MinesSelector();
    }
}

class MinesSelector extends Scene {
    private int rows = 10;
    private int cols = 10;
    private int mines = 15;
    private Button rm = new Button(width/5, uiScale/15*3, uiScale/15, "-5", new int[]{0,200,0}, new int[]{0,255,0}, new int[]{0,255,0});
    private Button rp = new Button(width/5*4, uiScale/15*3, uiScale/15, "+5", new int[]{0,200,0}, new int[]{0,255,0}, new int[]{0,255,0});
    private Button cm = new Button(width/5, uiScale/15*5, uiScale/15, "-5", new int[]{0,200,0}, new int[]{0,255,0}, new int[]{0,255,0});
    private Button cp = new Button(width/5*4, uiScale/15*5, uiScale/15, "+5", new int[]{0,200,0}, new int[]{0,255,0}, new int[]{0,255,0});
    private Button mm = new Button(width/5, uiScale/15*7, uiScale/15, "-5", new int[]{0,200,0}, new int[]{0,255,0}, new int[]{0,255,0});
    private Button mp = new Button(width/5*4, uiScale/15*7, uiScale/15, "+5", new int[]{0,200,0}, new int[]{0,255,0}, new int[]{0,255,0});
    private Button GO = new Button(width/2, uiScale/15*10, uiScale/15, "GO!", new int[]{0,200,0}, new int[]{0,255,0}, new int[]{0,255,0});
    public void draw() {
        background(0,0,0);
        textAlign(CENTER);
        textSize(uiScale/15);
        fill(0, 0, 0);
        rm.render();
        rp.render();
        cm.render();
        cp.render();
        mm.render();
        mp.render();
        
        GO.render();
        fill(255,255,255);
        text("Rows: "+rows, width/2, uiScale/15*3);
        text("Columns: "+cols, width/2, uiScale/15*5);
        text("Mine Percentage: "+mines+"%", width/2, uiScale/15*7);
    }
    public void keyEvent(int keyValue, boolean pressed) {
        if (keyValue == ENTER && !pressed) changeScene = new MinesGame(rows, cols, (int)(rows*cols*(mines/100.0)));
    }
    public void mouseEvent(int x, int y, boolean pressed) {
        if (pressed) return;
        if (rm.isClicked(x, y) && rows > 5) rows -= 5;
        if (rp.isClicked(x, y)) rows += 5;
        if (cm.isClicked(x, y) && cols > 5) cols -= 5;
        if (cp.isClicked(x, y)) cols += 5;
        if (mm.isClicked(x, y) && mines >= 5) mines -= 5;
        if (mp.isClicked(x, y) && mines < 100) mines += 5;
        if (GO.isClicked(x, y)) changeScene = new MinesGame(rows, cols, (int)(rows*cols*(mines/100.0)));
    }
}

class MinesGame extends Scene {
    private int w, h, mineNum;
    private boolean win = false;
    private boolean die = false;
    private boolean cheater = false;
    private Button ret, mm;
    Minefield m;
    public MinesGame(int w, int h, int mineNum) {
        this.w = w;
        this.h = h;
        this.mineNum = mineNum;
        if (this.mineNum <= 0) {
            cheater = true;
            this.mineNum = 100;
        }
        this.m = new Minefield(w, h, this.mineNum, 0, 0, width, height);
        ret = new Button(width/2, uiScale/15*10, uiScale/15, "Restart", new int[]{255,255,255}, new int[]{255,255,255}, new int[]{0,255,0});
        mm = new Button(width/2, uiScale/15*12, uiScale/15, "Change game settings", new int[]{255,255,255}, new int[]{255,255,255}, new int[]{0,255,0});
    }
    public void draw() {
        background(0,0,0);
        textAlign(CENTER);
        textSize(uiScale/15);
        m.draw();
        if (die) {
            fill(255, 0, 0, 50);
            rect(0,0,width,height);
            textSize(uiScale/10);
            fill(255, 255, 255);
            if (!cheater && mineNum != 100) {
                text("You Died!", width/2, height/2);
                ret.render();
                mm.render();
            } else if (!cheater && mineNum == 100) {
                text("What did you expect?", width/2, height/2);
                mm.render();
            } else {
                textSize(uiScale/10);
                text("Skill issue", width/2, height/2);
                textSize(uiScale/15);
                text("(there is no escape)", width/2, height*.6);
            }
        }
        else if (win) {
            fill(0, 0, 0, 100);
            rect(0,0,width,height);
            textSize(uiScale/10);
            fill(255, 255, 255);
            text("You Win!", width/2, height/2);
            ret.render();
            mm.render();
        }
    }
    public void keyEvent(int keyValue, boolean pressed) {
    }
    public void mouseEvent(int x, int y, boolean pressed) {
        if (pressed) return;
        if (!win && !die) {
            if (mouseButton == LEFT) {
                boolean res = m.diffuse(x, y);
                if (res) {
                    m.openAll();
                    m.unflagAll();
                    die = true;
                } else if (m.isCleared()) {
                    win = true;
                }
            }
            if (mouseButton == RIGHT) m.toggleFlag(x, y);
        } if ((die||win)&&(!cheater)) {
            if (ret.isClicked(x, y)) changeScene = new MinesGame(w, h, mineNum);
            if (mm.isClicked(x, y)) changeScene = new MinesSelector();
        }
    }
}


abstract class Widget {
    //basic drawable box with a clicked method and some template variables
    protected int[] boundingBox;
    protected int xCenter;
    protected int yCenter;
    protected int w;
    protected int h;
    protected boolean isClicked(int x, int y) {
        return boundingBox[0] <= x && x <= boundingBox[2] && boundingBox[1] <= y && y <= boundingBox[3];
    }
    public abstract void render();
}

class Button extends Widget {
    //a box with text
    protected String text_;
    protected int[] textColor;
    protected int[] hoverColor;
    protected int[] bgColor;
    public Button(int xCenter, int yCenter, int h, String text_, int[] textColor) {
        textSize(h*.75);
        int w = (int) (textWidth(text_)*1.5);
        boundingBox = new int[] {xCenter-(w/2), yCenter-(h/2), xCenter+w/2, yCenter+h/2};
        this.xCenter = xCenter;
        this.yCenter = yCenter;
        this.text_ = text_;
        this.w = w;
        this.h = h;
        this.textColor = textColor;
        this.hoverColor = textColor;
        this.bgColor = new int[]{150,150,150};
    }
    public Button(int xCenter, int yCenter, int h, String text_, int[] textColor, int[] hoverColor, int[] bgColor) {
        this(xCenter, yCenter, h, text_, textColor);
        this.hoverColor = hoverColor;
        this.bgColor = bgColor;
    }
    public void render() {
        stroke(bgColor[0], bgColor[1], bgColor[2]);
        fill(0,0,0);
        rect(boundingBox[0], boundingBox[1], w, h);
        if (isClicked(mouseX, mouseY)) {
            fill(hoverColor[0], hoverColor[1], hoverColor[2]);
        } else {
            fill(textColor[0], textColor[1], textColor[2]);
        }
        textSize(h*.75);
        textAlign(CENTER);
        text(this.text_, xCenter, yCenter+(h/4));
    }
}
