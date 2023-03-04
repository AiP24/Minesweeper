class Minefield {
    private int w, h, dx, dy, dw, dh, mineNum;
    private int clearedCount;
    private MineLocation[][] field;
    public Minefield(int w, int h, int mineNum, int dx, int dy, int dw, int dh) {
        this.w = w;
        this.h = h;
        this.dw = dw;
        this.dh = dh;
        this.dx = dx;
        this.dy = dy;
        this.mineNum = mineNum;
        field = new MineLocation[w][h];
        for (int i=0;i<mineNum;i++) {
            int x = -1;
            int y = -1;
            while (x==-1||(field[x][y]!=null)) {
                x=(int)(Math.random()*w);
                y=(int)(Math.random()*h);
            }
            field[x][y] = new MineLocation(true);
        }
        for (int i=0;i<field.length;i++) {
            for (int j=0;j<field[i].length;j++) {
                if (field[i][j] == null) field[i][j] = new MineLocation(false);
            }
        }
        for (int i=0;i<field.length;i++) {
            for (int j=0;j<field[i].length;j++) {
                if (!field[i][j].isBomb()) field[i][j].setSurrounding(surroundingSum(i, j));
            }
        }
    }
    private boolean validCoord(int x, int y) {
        return 0 <= x && x < w && 0 <= y && y < h;
    }
    public int surroundingSum(int x, int y) {
        int count = 0;
        if (validCoord(x-1, y-1)) count += (field[x-1][y-1].isBomb())?1:0;
        if (validCoord(x,   y-1)) count += (field[x  ][y-1].isBomb())?1:0;
        if (validCoord(x+1, y-1)) count += (field[x+1][y-1].isBomb())?1:0;
        //
        if (validCoord(x-1, y)) count += (field[x-1][y].isBomb())?1:0;
        //don't include current
        if (validCoord(x+1, y)) count += (field[x+1][y].isBomb())?1:0;
        //
        if (validCoord(x-1, y+1)) count += (field[x-1][y+1].isBomb())?1:0;
        if (validCoord(x,   y+1)) count += (field[x  ][y+1].isBomb())?1:0;
        if (validCoord(x+1, y+1)) count += (field[x+1][y+1].isBomb())?1:0;
        return count;
    }
    public MineLocation[][] getField() {return field;}
    public void draw() {
        //rect(sX, sY, w, h);
        for (int i=0;i<field.length;i++) {
            for (int j=0;j<field[i].length;j++) {
                field[i][j].draw(dx+dw/field.length*i, dy+dh/field[i].length*j, dw/field.length, dh/field[i].length);
            }
        }
    }
    public void openAll() {
        for (int i=0;i<field.length;i++) {
            for (int j=0;j<field[i].length;j++) {
                field[i][j].setOpen(true);
            }
        }
    }
    public void unflagAll() {
        for (int i=0;i<field.length;i++) {
            for (int j=0;j<field[i].length;j++) {
                field[i][j].setFlag(false);
            }
        }
    }
    public boolean isCleared() {
        int ct = 0;
        for (int i=0;i<field.length;i++) {
            for (int j=0;j<field[i].length;j++) {
                ct += (!field[i][j].isBomb()&&field[i][j].getOpen())?1:0;
            }
        }
        return ct==w*h-mineNum;
    }
    public boolean diffuse(int x, int y) {
        int i = (int)((double)x/dw*w);
        int j = (int)((double)y/dh*h);
        if (field[i][j].getFlag()) return false;
        field[i][j].setOpen(true);
        if (field[i][j].getSurrounding()==0) waterfall(i,j,true);
        return field[i][j].isBomb();
    }
    public void waterfall(int i, int j, boolean initial) {
        if (!validCoord(i,j)) return;
        if (field[i][j].getOpen()&&!initial) return;
        if (field[i][j].isBomb()) return;
        field[i][j].setOpen(true);
        field[i][j].setFlag(false);
        if (field[i][j].getSurrounding()!=0) return;
        
        if (validCoord(i-1, j-1)) waterfall(i-1, j-1, false);
        if (validCoord(i,   j-1)) waterfall(i  , j-1, false);
        if (validCoord(i+1, j-1)) waterfall(i+1, j-1, false);
        //
        if (validCoord(i-1, j  )) waterfall(i-1, j  , false);
        //don't include current
        if (validCoord(i+1, j  )) waterfall(i+1, j  , false);
        //
        if (validCoord(i-1, j+1)) waterfall(i-1, j+1, false);
        if (validCoord(i,   j+1)) waterfall(i  , j+1, false);
        if (validCoord(i+1, j+1)) waterfall(i+1, j+1, false);
    }
    public void toggleFlag(int x, int y) {
        int i = (int)((double)x/dw*w);
        int j = (int)((double)y/dh*h);
        if (!field[i][j].getOpen()||field[i][j].getFlag()) field[i][j].setFlag(!field[i][j].getFlag());
    }
}
class MineLocation {
    boolean bomb;
    boolean open = false;
    boolean flagged = false;
    int surrounding = 0;
    public MineLocation(boolean b) {
        bomb = b;
    }
    public void setSurrounding(int s) {surrounding=s;}
    public int getSurrounding() {return surrounding;}
    public boolean isBomb() {return bomb;}
    public void draw(int sX, int sY, int w, int h) {
        stroke(0,255,0);
        fill(0,0,0);
        rect(sX, sY, w, h);
        if (flagged) {
            //fill(255, 255, 0);
            //rect(sX, sY, w, h);
            stroke(0,255, 0);
            triangle(sX+(w/2), sY+h*.1, sX+w*.1, sY+h*.9, sX+w*.9, sY+h*.9);
            fill(0, 255, 0);
            text("!", sX+w/2, sY+h*.8);
        } else if (open && !bomb) {
            fill(0, 0, 0); rect(sX, sY, w, h);
            if (surrounding != 0) {fill(0,255,0); text(surrounding, sX+w/2, sY+h*.9);}
            else {fill(0, 100, 0); line(sX, sY, sX+w, sY+h);}
        } else if (open && bomb) {
            fill(255, 0, 0);
            rect(sX, sY, w, h);
            fill(0,255,0);
            text("B", sX+w/2, sY+h*.9);
        } else if (!open) {
            fill(0,0,0);
            rect(sX, sY, w, h);
        }
    }
    public void setFlag(boolean f){flagged=f;}
    public boolean getFlag(){return flagged;}
    public void setOpen(boolean o) {
        open = o;
    }
    public boolean getOpen() {return open;}
}
