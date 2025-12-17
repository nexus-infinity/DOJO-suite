"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.metadata = void 0;
exports.default = RootLayout;
require("./globals.css");
var google_1 = require("next/font/google");
var toaster_1 = require("@/components/ui/toaster");
var inter = (0, google_1.Inter)({ subsets: ['latin'] });
exports.metadata = {
    title: {
        default: 'Nexus-Infinity Platform',
        template: '%s | Nexus-Infinity Platform',
    },
    description: 'A platform for sharing and advocating community stories',
    keywords: ['advocacy', 'community', 'stories', 'platform'],
    authors: [{ name: 'Nexus-Infinity Team' }],
    creator: 'Nexus-Infinity Organization',
    themeColor: [
        { media: '(prefers-color-scheme: light)', color: 'white' },
        { media: '(prefers-color-scheme: dark)', color: 'black' },
    ],
    openGraph: {
        type: 'website',
        locale: 'en_US',
        url: 'https://nexus-infinity.org',
        siteName: 'Nexus-Infinity Platform',
        title: 'Nexus-Infinity Platform',
        description: 'A platform for sharing and advocating community stories',
        images: [
            {
                url: 'https://nexus-infinity.org/og-image.jpg',
                width: 1200,
                height: 630,
                alt: 'Nexus-Infinity Platform',
            },
        ],
    },
    twitter: {
        card: 'summary_large_image',
        title: 'Nexus-Infinity Platform',
        description: 'A platform for sharing and advocating community stories',
        images: ['https://nexus-infinity.org/twitter-image.jpg'],
        creator: '@NexusInfinity',
    },
    robots: {
        index: true,
        follow: true,
        googleBot: {
            index: true,
            follow: true,
            'max-video-preview': -1,
            'max-image-preview': 'large',
            'max-snippet': -1,
        },
    },
};
function RootLayout(_a) {
    var children = _a.children;
    return (React.createElement("html", { lang: "en" },
        React.createElement("body", { className: inter.className },
            children,
            React.createElement(toaster_1.Toaster, null))));
}
