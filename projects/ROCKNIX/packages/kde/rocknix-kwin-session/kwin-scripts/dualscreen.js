const mainName = "@MAIN@";
const secondName = "@SECOND@";
const secondary = /Secondary|\[w2\]|Sub|Bottom|Screen 2|GamePad/;

function place(window) {
    if (!window.normalWindow || !window.fullScreen) {
        return;
    }
    const name = (window.resourceClass === "lowerdeck" || secondary.test(window.caption)) ? secondName : mainName;
    const output = workspace.screens.find(screen => screen.name === name);
    if (output && window.output !== output) {
        workspace.sendClientToScreen(window, output);
    }
}

workspace.windowList().forEach(place);
workspace.windowAdded.connect(window => {
    place(window);
    window.captionChanged.connect(() => place(window));
    window.fullScreenChanged.connect(() => place(window));
});
