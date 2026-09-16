/**
 * FIELD Brand Kit — Sacred Geometry Visual System (Canonical v1.0.0-GOLDEN)
 * Notion: d24e9b49a37c428c8ccafb7b63ef0f1b
 *
 * Manifestation phenotype only (◼︎ DOJO web). Not chamber authority.
 * Accent Base hues are the deliberate highlight states from the Brand Kit.
 */

export const BRAND_KIT = {
  version: '1.0.0-GOLDEN',
  notionPageId: 'd24e9b49a37c428c8ccafb7b63ef0f1b',
  /** Default Surface Profile — Dark Teal “Future Path” */
  canvas: '#0A1A1A',
  structure: '#1A7A7A',
  textPrimary: '#FAFAFA',
  textSecondary: '#CCCCCC',
  wireframe: '#6B4D9B',
  activeEnergy: '#00D9D9',
  wisdomDot: '#FFD700',
  deepTeal: '#0D4D4D',
  /** Geometric neutrals */
  factAnchor: '#2C3E50',
  documentAnchor: '#ECF0F1',
  timelineAnchor: '#34495E',
  /** Chamber Accent Base (chakra-aligned) */
  chambers: {
    obiwan: '#9370DB', // 963 Accent Base
    kings: '#4B0082', // 852 Accent Base (Indigo)
    dojo: '#0066CC', // 741 Accent Base
    heart: '#00CC66', // 639 Accent Base
    atlas: '#FFD700', // 528 Accent Base
    tata: '#FF8C00', // 432 Accent Base
    akron: '#CC0000', // 396 Accent Base (Root)
    /** 717 not in Brand Kit frequency table — Days of Future Past bridge */
    arkadas: '#6B4D9B',
  },
} as const

export type BrandChamberKey = keyof typeof BRAND_KIT.chambers
