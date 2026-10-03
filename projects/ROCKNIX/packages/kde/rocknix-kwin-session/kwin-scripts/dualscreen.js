const mainName = "@MAIN@";
const secondName = "@SECOND@";
const secondary = /Secondary|\[w2\]|Sub|Bottom|Screen 2|GamePad/;
const spanning = ["drastic"];
const keptShown = new Set();

function keepShown(window) {
    if (window.minimized) {
        window.minimized = false;
    }
}

function place(window) {
    if (!window.normalWindow || spanning.includes(window.resourceClass)) {
        return;
    }
    const name = (window.resourceClass === "lowerdeck" || secondary.test(window.caption)) ? secondName : mainName;
    const output = workspace.screens.find(screen => screen.name === name);
    if (output && window.output !== output) {
        workspace.sendClientToScreen(window, output);
    }
    if (name === secondName) {
        const id = String(window.internalId);
        if (!keptShown.has(id)) {
            keptShown.add(id);
            window.minimizedChanged.connect(() => keepShown(window));
        }
        keepShown(window);
    }
}

workspace.windowList().forEach(place);
workspace.windowAdded.connect(window => {
    place(window);
    window.captionChanged.connect(() => place(window));
});
