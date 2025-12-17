"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = RootLayout;
var native_1 = require("@react-navigation/native");
var expo_font_1 = require("expo-font");
var expo_router_1 = require("expo-router");
var SplashScreen = __importStar(require("expo-splash-screen"));
var react_1 = require("react");
require("react-native-reanimated");
var useColorScheme_1 = require("@/hooks/useColorScheme");
// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();
function RootLayout() {
    var colorScheme = (0, useColorScheme_1.useColorScheme)();
    var loaded = (0, expo_font_1.useFonts)({
        SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
    })[0];
    (0, react_1.useEffect)(function () {
        if (loaded) {
            SplashScreen.hideAsync();
        }
    }, [loaded]);
    if (!loaded) {
        return null;
    }
    return (React.createElement(native_1.ThemeProvider, { value: colorScheme === 'dark' ? native_1.DarkTheme : native_1.DefaultTheme },
        React.createElement(expo_router_1.Stack, null,
            React.createElement(expo_router_1.Stack.Screen, { name: "(tabs)", options: { headerShown: false } }),
            React.createElement(expo_router_1.Stack.Screen, { name: "+not-found" }))));
}
