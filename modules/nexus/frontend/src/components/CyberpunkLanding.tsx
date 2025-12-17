import React, { useRef, useEffect, useState } from 'react'
import { Canvas, useFrame, useThree } from '@react-three/fiber'
import { Text, OrbitControls, useGLTF, Environment, MeshDistortMaterial } from '@react-three/drei'
import { motion } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import { Mesh } from 'three'

// Preloading assets
useGLTF.preload('/assets/3d/duck.glb')

// Floating Cube Component
function FloatingCube({ position }: { position: [number, number, number] }) {
  const mesh = useRef<Mesh>(null!)
  const [hovered, setHover] = useState(false)

  useFrame((state) => {
    mesh.current.position.y = position[1] + Math.sin(state.clock.elapsedTime) * 0.1
    mesh.current.rotation.x = mesh.current.rotation.y += 0.01
  })

  return (
    <mesh
      ref={mesh}
      position={position}
      scale={hovered ? 1.1 : 1}
      onPointerOver={() => setHover(true)}
      onPointerOut={() => setHover(false)}
    >
      <boxGeometry args={[1, 1, 1]} />
      <MeshDistortMaterial color={hovered ? "hotpink" : "cyan"} speed={5} distort={0.3} />
    </mesh>
  )
}

// Floating Text Component
function FloatingText({ text, position }: { text: string, position: [number, number, number] }) {
  const { camera } = useThree()
  const textRef = useRef<Mesh>(null!)

  useFrame(() => {
    textRef.current.lookAt(camera.position)
  })

  return (
    <Text
      ref={textRef}
      position={position}
      color="lime"
      fontSize={0.5}
      maxWidth={2}
      lineHeight={1}
      letterSpacing={0.02}
      textAlign="center"
      font="https://fonts.gstatic.com/s/raleway/v14/1Ptrg8zYS_SKggPNwK4vaqI.woff"
      anchorX="center"
      anchorY="middle"
    >
      {text}
    </Text>
  )
}

// Nexus Logo Component (3D Model)
function NexusLogo() {
  const { scene } = useGLTF('/assets/3d/duck.glb')
  const meshRef = useRef<THREE.Group>(null!)

  useFrame((state) => {
    if (meshRef.current) {
      meshRef.current.rotation.y = Math.sin(state.clock.elapsedTime) * 0.3
    }
  })

  if (!scene) {
    return <Text position={[0, 0, 0]} color="red" fontSize={0.5}>Failed to load model</Text>
  }

  return (
    <primitive object={scene} ref={meshRef} position={[0, 0, 0]} scale={[2, 2, 2]}>
      <meshStandardMaterial color="gold" />
    </primitive>
  )
}

// Main Cyberpunk Landing Page
export default function CyberpunkLanding() {
  const [entered, setEntered] = useState(false)
  const navigate = useNavigate()

  useEffect(() => {
    const timer = setTimeout(() => setEntered(true), 1000)
    return () => clearTimeout(timer)
  }, [])

  const handleEnterNexus = () => {
    navigate('/dashboard')
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 2 }}
      className="w-full h-screen bg-black"
    >
      <Canvas camera={{ position: [0, 0, 10] }}>
        <color attach="background" args={['black']} />
        <ambientLight intensity={0.5} />
        <pointLight position={[10, 10, 10]} />
        <OrbitControls enableZoom={false} />
        <FloatingCube position={[1, 1, 0]} />
        <FloatingText text="Welcome to Nexus" position={[0, 2, 0]} />
        <NexusLogo />
      </Canvas>
      {entered && (
        <motion.button
          className="absolute bottom-10 left-1/2 transform -translate-x-1/2 px-6 py-2 bg-blue-500 text-white rounded-lg"
          onClick={handleEnterNexus}
        >
          Enter the Nexus
        </motion.button>
      )}
    </motion.div>
  )
}
