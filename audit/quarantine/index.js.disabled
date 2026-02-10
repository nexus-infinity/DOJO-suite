"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = HomeScreen;
var react_native_1 = require("react-native");
var HelloWave_1 = require("@/components/HelloWave");
var ParallaxScrollView_1 = __importDefault(require("@/components/ParallaxScrollView"));
var ThemedText_1 = require("@/components/ThemedText");
var ThemedView_1 = require("@/components/ThemedView");
function HomeScreen() {
    return (React.createElement(ParallaxScrollView_1.default, { headerBackgroundColor: { light: '#A1CEDC', dark: '#1D3D47' }, headerImage: React.createElement(react_native_1.Image, { source: require('@/assets/images/partial-react-logo.png'), style: styles.reactLogo }) },
        React.createElement(ThemedView_1.ThemedView, { style: styles.titleContainer },
            React.createElement(ThemedText_1.ThemedText, { type: "title" }, "Welcome!"),
            React.createElement(HelloWave_1.HelloWave, null)),
        React.createElement(ThemedView_1.ThemedView, { style: styles.stepContainer },
            React.createElement(ThemedText_1.ThemedText, { type: "subtitle" }, "Step 1: Try it"),
            React.createElement(ThemedText_1.ThemedText, null,
                "Edit ",
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app/(tabs)/index.tsx"),
                " to see changes. Press",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, react_native_1.Platform.select({ ios: 'cmd + d', android: 'cmd + m' })),
                ' ',
                "to open developer tools.")),
        React.createElement(ThemedView_1.ThemedView, { style: styles.stepContainer },
            React.createElement(ThemedText_1.ThemedText, { type: "subtitle" }, "Step 2: Explore"),
            React.createElement(ThemedText_1.ThemedText, null, "Tap the Explore tab to learn more about what's included in this starter app.")),
        React.createElement(ThemedView_1.ThemedView, { style: styles.stepContainer },
            React.createElement(ThemedText_1.ThemedText, { type: "subtitle" }, "Step 3: Get a fresh start"),
            React.createElement(ThemedText_1.ThemedText, null,
                "When you're ready, run",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "npm run reset-project"),
                " to get a fresh",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app"),
                " directory. This will move the current",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app"),
                " to",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app-example"),
                "."))));
}
var styles = react_native_1.StyleSheet.create({
    titleContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
    },
    stepContainer: {
        gap: 8,
        marginBottom: 8,
    },
    reactLogo: {
        height: 178,
        width: 290,
        bottom: 0,
        left: 0,
        position: 'absolute',
    },
});
