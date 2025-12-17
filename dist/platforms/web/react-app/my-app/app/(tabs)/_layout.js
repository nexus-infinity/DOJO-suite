"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = TabLayout;
var expo_router_1 = require("expo-router");
var react_1 = __importDefault(require("react"));
var TabBarIcon_1 = require("@/components/navigation/TabBarIcon");
var Colors_1 = require("@/constants/Colors");
var useColorScheme_1 = require("@/hooks/useColorScheme");
function TabLayout() {
    var colorScheme = (0, useColorScheme_1.useColorScheme)();
    return (react_1.default.createElement(expo_router_1.Tabs, { screenOptions: {
            tabBarActiveTintColor: Colors_1.Colors[colorScheme !== null && colorScheme !== void 0 ? colorScheme : 'light'].tint,
            headerShown: false,
        } },
        react_1.default.createElement(expo_router_1.Tabs.Screen, { name: "index", options: {
                title: 'Home',
                tabBarIcon: function (_a) {
                    var color = _a.color, focused = _a.focused;
                    return (react_1.default.createElement(TabBarIcon_1.TabBarIcon, { name: focused ? 'home' : 'home-outline', color: color }));
                },
            } }),
        react_1.default.createElement(expo_router_1.Tabs.Screen, { name: "explore", options: {
                title: 'Explore',
                tabBarIcon: function (_a) {
                    var color = _a.color, focused = _a.focused;
                    return (react_1.default.createElement(TabBarIcon_1.TabBarIcon, { name: focused ? 'code-slash' : 'code-slash-outline', color: color }));
                },
            } })));
}
