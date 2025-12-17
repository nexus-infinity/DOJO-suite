import React from 'react'
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export default function NewFeature() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>New Feature</CardTitle>
      </CardHeader>
      <CardContent>
        <p>This is a new feature we've added to our Nexus-Infinity project.</p>
      </CardContent>
    </Card>
  )
}