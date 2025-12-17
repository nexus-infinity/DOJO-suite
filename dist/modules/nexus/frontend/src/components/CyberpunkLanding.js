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
exports.default = CyberpunkLanding;
var react_1 = __importStar(require("react"));
var fiber_1 = require("@react-three/fiber");
var drei_1 = require("@react-three/drei");
var framer_motion_1 = require("framer-motion");
var react_router_dom_1 = require("react-router-dom");
// Preloading assets
drei_1.useGLTF.preload('/assets/3d/duck.glb');
// Floating Cube Component
function FloatingCube(_a) {
    var position = _a.position;
    var mesh = (0, react_1.useRef)(null);
    var _b = (0, react_1.useState)(false), hovered = _b[0], setHover = _b[1];
    (0, fiber_1.useFrame)(function (state) {
        mesh.current.position.y = position[1] + Math.sin(state.clock.elapsedTime) * 0.1;
        mesh.current.rotation.x = mesh.current.rotation.y += 0.01;
    });
    return (react_1.default.createElement("mesh", { ref: mesh, position: position, scale: hovered ? 1.1 : 1, onPointerOver: function () { return setHover(true); }, onPointerOut: function () { return setHover(false); } },
        react_1.default.createElement("boxGeometry", { args: [1, 1, 1] }),
        react_1.default.createElement(drei_1.MeshDistortMaterial, { color: hovered ? "hotpink" : "cyan", speed: 5, distort: 0.3 })));
}
// Floating Text Component
function FloatingText(_a) {
    var text = _a.text, position = _a.position;
    var camera = (0, fiber_1.useThree)().camera;
    var textRef = (0, react_1.useRef)(null);
    (0, fiber_1.useFrame)(function () {
        textRef.current.lookAt(camera.position);
    });
    return (react_1.default.createElement(drei_1.Text, { ref: textRef, position: position, color: "lime", fontSize: 0.5, maxWidth: 2, lineHeight: 1, letterSpacing: 0.02, textAlign: "center", font: "https://fonts.gstatic.com/s/raleway/v14/1Ptrg8zYS_SKggPNwK4vaqI.woff", anchorX: "center", anchorY: "middle" }, text));
}
// Nexus Logo Component (3D Model)
function NexusLogo() {
    var scene = (0, drei_1.useGLTF)('/assets/3d/duck.glb').scene;
    var meshRef = (0, react_1.useRef)(null);
    (0, fiber_1.useFrame)(function (state) {
        if (meshRef.current) {
            meshRef.current.rotation.y = Math.sin(state.clock.elapsedTime) * 0.3;
        }
    });
    if (!scene) {
        return react_1.default.createElement(drei_1.Text, { position: [0, 0, 0], color: "red", fontSize: 0.5 }, "Failed to load model");
    }
    return (react_1.default.createElement("primitive", { object: scene, ref: meshRef, position: [0, 0, 0], scale: [2, 2, 2] },
        react_1.default.createElement("meshStandardMaterial", { color: "gold" })));
}
// Main Cyberpunk Landing Page
function CyberpunkLanding() {
    var _a = (0, react_1.useState)(false), entered = _a[0], setEntered = _a[1];
    var navigate = (0, react_router_dom_1.useNavigate)();
    (0, react_1.useEffect)(function () {
        var timer = setTimeout(function () { return setEntered(true); }, 1000);
        return function () { return clearTimeout(timer); };
    }, []);
    var handleEnterNexus = function () {
        navigate('/dashboard');
    };
    return (react_1.default.createElement(framer_motion_1.motion.div, { initial: { opacity: 0 }, animate: { opacity: 1 }, transition: { duration: 2 }, className: "w-full h-screen bg-black" },
        react_1.default.createElement(fiber_1.Canvas, { camera: { position: [0, 0, 10] } },
            react_1.default.createElement("color", { attach: "background", args: ['black'] }),
            react_1.default.createElement("ambientLight", { intensity: 0.5 }),
            react_1.default.createElement("pointLight", { position: [10, 10, 10] }),
            react_1.default.createElement(drei_1.OrbitControls, { enableZoom: false }),
            react_1.default.createElement(FloatingCube, { position: [1, 1, 0] }),
            react_1.default.createElement(FloatingText, { text: "Welcome to Nexus", position: [0, 2, 0] }),
            react_1.default.createElement(NexusLogo, null)),
        entered && (react_1.default.createElement(framer_motion_1.motion.button, { className: "absolute bottom-10 left-1/2 transform -translate-x-1/2 px-6 py-2 bg-blue-500 text-white rounded-lg", onClick: handleEnterNexus }, "Enter the Nexus"))));
}
