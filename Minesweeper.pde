Scene scene;
int uiScale;
public void setup() {
    size(750, 750);
    uiScale = (width+height)/2;
    scene = new MainMenu();
    //scene.setup();
}

public void draw() {
    if (scene == null) return;
    if (scene.sceneChanged()) {
        scene = scene.getNewScene();
        //scene.setup();
    }
    scene.draw();
}

public void keyPressed() {
    scene.keyEvent((key == CODED) ? keyCode : key, true);
}
public void keyReleased() {
    scene.keyEvent((key == CODED) ? keyCode : key, false);
}
public void mousePressed() {
    scene.mouseEvent(mouseX, mouseY, true);
}
public void mouseReleased() {
    scene.mouseEvent(mouseX, mouseY, false);
}
