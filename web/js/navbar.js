const HIGHLIGHT_COLORS = [
    '#e60000', // red
    '#009e30', // green
    '#d6aa00', // yellow
    '#0066ff', // blue
    '#a020f0', // violet
    '#ff7500'  // orange
];

let highlightColorIndex = 0;

function cycleHighlightColor() {
    highlightColorIndex =
        (highlightColorIndex + 1) % HIGHLIGHT_COLORS.length;

    $('#highlight-color-indicator').css(
        'background-color',
        getHighlightColor()
    );
}

function getHighlightColor() {
    return HIGHLIGHT_COLORS[highlightColorIndex];
}

