"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = NotFoundScreen;
var expo_router_1 = require("expo-router");
var react_native_1 = require("react-native");
var ThemedText_1 = require("@/components/ThemedText");
var ThemedView_1 = require("@/components/ThemedView");
function NotFoundScreen() {
    return (React.createElement(React.Fragment, null,
        React.createElement(expo_router_1.Stack.Screen, { options: { title: 'Oops!' } }),
        React.createElement(ThemedView_1.ThemedView, { style: styles.container },
            React.createElement(ThemedText_1.ThemedText, { type: "title" }, "This screen doesn't exist."),
            React.createElement(expo_router_1.Link, { href: "/", style: styles.link },
                React.createElement(ThemedText_1.ThemedText, { type: "link" }, "Go to home screen!")))));
}
var styles = react_native_1.StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        padding: 20,
    },
    link: {
        marginTop: 15,
        paddingVertical: 15,
    },
});
