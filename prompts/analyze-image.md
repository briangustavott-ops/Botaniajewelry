# Prompt — Análisis de imagen (W2 asset-analyzer)

Prompt enviado a Claude Vision en el nodo **Build Claude Payload** de W2.
El modelo recibe la imagen como base64 + este texto.

---

```
Analiza esta imagen de joyería artesanal de resina. Responde ÚNICAMENTE con un JSON
válido con esta estructura exacta, sin texto adicional ni bloques de código markdown:

{
  "tipo": "foto",
  "categoria": "pendientes" | "anillos" | "colgantes" | null,
  "colores": "colores principales de la pieza y flores",
  "materiales": "materiales detectados separados por coma (resina, flores secas, metal dorado...)",
  "caption_es": "caption atractivo en español para Instagram y web, máx 150 caracteres",
  "caption_en": "attractive English caption for Etsy listing, max 150 characters",
  "hashtags": "#resinajewelry #joyeriaresina #handmadejewelry #joyeriaartesanal #flowerjewelry (8-12 hashtags)",
  "plataformas_destino": "instagram,web,etsy" | "instagram,web" | "instagram",
  "descripcion": "descripción breve del producto en español"
}

Criterio para plataformas_destino:
- Incluir siempre instagram para fotografías
- Incluir web si la composición y calidad son buenas para catálogo
- Incluir etsy SOLO si el producto se ve claramente con fondo neutro/blanco y buena iluminación
```

---

## Notas de ajuste

| Campo | Criterio actual | Posible ajuste |
|-------|----------------|----------------|
| `caption_es` | Máx 150 caracteres | Ampliar si se quieren captions más largos para la web |
| `caption_en` | Máx 150 caracteres | Etsy permite hasta 55 chars en título — el caption es para description |
| `hashtags` | 8-12 hashtags | Instagram recomienda 3-5 muy relevantes; ajustar si se prefieren menos |
| `plataformas_destino` | Fondo neutro → incluye etsy | Afinar criterios según resultados reales |

## Modelo utilizado

`claude-opus-4-5` — mayor precisión en detección de producto y generación de texto.
Cambiar a `claude-haiku-4-5` si se prioriza velocidad/coste sobre calidad.
