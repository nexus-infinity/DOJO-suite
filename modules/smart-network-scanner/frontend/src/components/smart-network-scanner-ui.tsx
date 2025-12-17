import React, { useState, useEffect } from 'react'
import { SmartNetworkScanner } from '../services/scanner'
import { Device } from '../types/device'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'

export function SmartNetworkScannerUI() {
  const [devices, setDevices] = useState<Device[]>([])
  const [isScanning, setIsScanning] = useState(false)
  const [scanner] = useState(() => new SmartNetworkScanner())

  useEffect(() => {
    const scanNetwork = async () => {
      setIsScanning(true)
      const scannedDevices = await scanner.scanNetwork()
      setDevices(scannedDevices)
      setIsScanning(false)
    }

    scanNetwork()

    scanner.monitorNetworkChanges((updatedDevices) => {
      setDevices(updatedDevices)
    })

    return () => {
      scanner.stopMonitoring()
    }
  }, [scanner])

  const deviceTypes = [...new Set(devices.map(device => device.type))]

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Smart Network Scanner</CardTitle>
      </CardHeader>
      <CardContent>
        {isScanning ? (
          <p className="text-blue-600">Scanning network...</p>
        ) : (
          <Tabs defaultValue="all" className="w-full">
            <TabsList className="grid w-full grid-cols-2 lg:grid-cols-5">
              <TabsTrigger value="all">All</TabsTrigger>
              {deviceTypes.map(type => (
                <TabsTrigger key={type} value={type}>{type}</TabsTrigger>
              ))}
            </TabsList>
            <TabsContent value="all">
              <DeviceList devices={devices} />
            </TabsContent>
            {deviceTypes.map(type => (
              <TabsContent key={type} value={type}>
                <DeviceList devices={devices.filter(device => device.type === type)} />
              </TabsContent>
            ))}
          </Tabs>
        )}
      </CardContent>
    </Card>
  )
}

function DeviceList({ devices }: { devices: Device[] }) {
  return (
    <ul className="space-y-2">
      {devices.map((device) => (
        <li key={device.id}>
          <Card>
            <CardContent className="p-4">
              <h3 className="font-medium">{device.name}</h3>
              <p className="text-sm text-muted-foreground">IP: {device.ip}</p>
              <p className="text-sm text-muted-foreground">Type: {device.type}</p>
              <p className="text-sm text-muted-foreground">Status: {device.status}</p>
            </CardContent>
          </Card>
        </li>
      ))}
    </ul>
  )
}