// backend/src/modules/cobranza/storage.service.ts
import { createClient } from '@supabase/supabase-js'
import { randomUUID } from 'crypto'
import { MultipartFile } from '@fastify/multipart'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_KEY!
)

const BUCKET = 'comprobantes'
const MAX_SIZE_BYTES = 5 * 1024 * 1024  // 5 MB
const ALLOWED_TYPES  = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf']

export class StorageService {
  async subirComprobante(file: MultipartFile, casaId: number): Promise<string> {
    // Validaciones
    if (!ALLOWED_TYPES.includes(file.mimetype)) {
      throw new Error('Tipo de archivo no permitido. Use JPG, PNG, WEBP o PDF.')
    }

    const buffer = await file.toBuffer()
    if (buffer.byteLength > MAX_SIZE_BYTES) {
      throw new Error('Archivo demasiado grande. Máximo 5 MB.')
    }

    const ext      = file.filename.split('.').pop()
    const nombre   = `casa-${casaId}/${randomUUID()}.${ext}`

    const { error } = await supabase.storage
      .from(BUCKET)
      .upload(nombre, buffer, {
        contentType: file.mimetype,
        upsert: false,
      })

    if (error) throw new Error(`Error al subir archivo: ${error.message}`)

    // URL pública firmada (válida 10 años — comprobantes son permanentes)
    const { data } = supabase.storage
      .from(BUCKET)
      .getPublicUrl(nombre)

    return data.publicUrl
  }

  async eliminarComprobante(url: string) {
    // Extraer path del bucket desde la URL pública
    const path = url.split(`/storage/v1/object/public/${BUCKET}/`)[1]
    if (!path) return
    await supabase.storage.from(BUCKET).remove([path])
  }
}
