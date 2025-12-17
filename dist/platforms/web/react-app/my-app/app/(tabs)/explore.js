"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = TabTwoScreen;
var Ionicons_1 = __importDefault(require("@expo/vector-icons/Ionicons"));
var react_native_1 = require("react-native");
var Collapsible_1 = require("@/components/Collapsible");
var ExternalLink_1 = require("@/components/ExternalLink");
var ParallaxScrollView_1 = __importDefault(require("@/components/ParallaxScrollView"));
var ThemedText_1 = require("@/components/ThemedText");
var ThemedView_1 = require("@/components/ThemedView");
function TabTwoScreen() {
    return (React.createElement(ParallaxScrollView_1.default, { headerBackgroundColor: { light: '#D0D0D0', dark: '#353636' }, headerImage: React.createElement(Ionicons_1.default, { size: 310, name: "code-slash", style: styles.headerImage }) },
        React.createElement(ThemedView_1.ThemedView, { style: styles.titleContainer },
            React.createElement(ThemedText_1.ThemedText, { type: "title" }, "Explore")),
        React.createElement(ThemedText_1.ThemedText, null, "This app includes example code to help you get started."),
        React.createElement(Collapsible_1.Collapsible, { title: "File-based routing" },
            React.createElement(ThemedText_1.ThemedText, null,
                "This app has two screens:",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app/(tabs)/index.tsx"),
                " and",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app/(tabs)/explore.tsx")),
            React.createElement(ThemedText_1.ThemedText, null,
                "The layout file in ",
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app/(tabs)/_layout.tsx"),
                ' ',
                "sets up the tab navigator."),
            React.createElement(ExternalLink_1.ExternalLink, { href: "https://docs.expo.dev/router/introduction" },
                React.createElement(ThemedText_1.ThemedText, { type: "link" }, "Learn more"))),
        React.createElement(Collapsible_1.Collapsible, { title: "Android, iOS, and web support" },
            React.createElement(ThemedText_1.ThemedText, null,
                "You can open this project on Android, iOS, and the web. To open the web version, press",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "w"),
                " in the terminal running this project.")),
        React.createElement(Collapsible_1.Collapsible, { title: "Images" },
            React.createElement(ThemedText_1.ThemedText, null,
                "For static images, you can use the ",
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "@2x"),
                " and",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "@3x"),
                " suffixes to provide files for different screen densities"),
            React.createElement(react_native_1.Image, { source: require('@/assets/images/react-logo.png'), style: { alignSelf: 'center' } }),
            React.createElement(ExternalLink_1.ExternalLink, { href: "https://reactnative.dev/docs/images" },
                React.createElement(ThemedText_1.ThemedText, { type: "link" }, "Learn more"))),
        React.createElement(Collapsible_1.Collapsible, { title: "Custom fonts" },
            React.createElement(ThemedText_1.ThemedText, null,
                "Open ",
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "app/_layout.tsx"),
                " to see how to load",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { style: { fontFamily: 'SpaceMono' } }, "custom fonts such as this one.")),
            React.createElement(ExternalLink_1.ExternalLink, { href: "https://docs.expo.dev/versions/latest/sdk/font" },
                React.createElement(ThemedText_1.ThemedText, { type: "link" }, "Learn more"))),
        React.createElement(Collapsible_1.Collapsible, { title: "Light and dark mode components" },
            React.createElement(ThemedText_1.ThemedText, null,
                "This template has light and dark mode support. The",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "useColorScheme()"),
                " hook lets you inspect what the user's current color scheme is, and so you can adjust UI colors accordingly."),
            React.createElement(ExternalLink_1.ExternalLink, { href: "https://docs.expo.dev/develop/user-interface/color-themes/" },
                React.createElement(ThemedText_1.ThemedText, { type: "link" }, "Learn more"))),
        React.createElement(Collapsible_1.Collapsible, { title: "Animations" },
            React.createElement(ThemedText_1.ThemedText, null,
                "This template includes an example of an animated component. The",
                ' ',
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "components/HelloWave.tsx"),
                " component uses the powerful ",
                React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "react-native-reanimated"),
                " library to create a waving hand animation."),
            react_native_1.Platform.select({
                ios: (React.createElement(ThemedText_1.ThemedText, null,
                    "The ",
                    React.createElement(ThemedText_1.ThemedText, { type: "defaultSemiBold" }, "components/ParallaxScrollView.tsx"),
                    ' ',
                    "component provides a parallax effect for the header image.")),
            }))));
}
var styles = react_native_1.StyleSheet.create({
    headerImage: {
        color: '#808080',
        bottom: -90,
        left: -35,
        position: 'absolute',
    },
    titleContainer: {
        flexDirection: 'row',
        gap: 8,
    },
});
