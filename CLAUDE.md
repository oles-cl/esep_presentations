# Contexto del proyecto: esep_presentations

## Descripción general
Repositorio de presentaciones del **Observatorio de Violencia y Legitimidad Social (OLES)** basadas en datos del Estudio de Percepciones de Seguridad y Policías en Chile (ESEP).

**Investigadora principal:** Monica Gerber (Universidad Diego Portales / Escuela de Gobierno UC)

---

## Estructura del repositorio

```
esep_presentations/
├── data/
│   ├── esep_w0.rds              # Datos Ola 0 (Sept–Nov 2023, n≈5304)
│   ├── ficha_tecnica_w0.xlsx
│   └── demographics_ola_0.xlsx
├── presentation/
│   ├── index.qmd                # Presentación principal Ola 0 (RevealJS)
│   └── 2026_mesa_redonda/       # Presentación mesa redonda 31/03/2026
│       ├── mesa_redonda.qmd     # ← ARCHIVO PRINCIPAL (21 láminas)
│       ├── mesa_redonda.html    # Output renderizado
│       ├── graficos.R           # Script de gráficos de barras (p1, p2, p3)
│       ├── css/
│       │   ├── custom.css       # Tema visual completo
│       │   └── header-logos.html  # Logos fijos en todas las láminas
│       └── img/                 # Imágenes y gráficos usados en la presentación
└── CLAUDE.md                    # Este archivo
```

---

## Presentación mesa redonda (`mesa_redonda.qmd`)

### Configuración RevealJS
- Tema base: `white` + `css/custom.css`
- `embed-resources: true` (HTML autocontenido)
- Logos fijos arriba: **Logo OLES 2.png** (izquierda) y **logo_eeg_uc.png** (derecha) — inyectados via `include-before-body: css/header-logos.html`
- Sin footer, sin logo nativo de RevealJS
- Transición: `fade`

### Estructura de las 21 láminas
| # | Título | Contenido |
|---|--------|-----------|
| 1 | Portada | Título, Monica Gerber, Escuela de Gobierno UC – OLES, 31 de marzo 2026 |
| 2 | Legitimidad Social | Dos columnas: definición + dimensiones |
| 3 | Legitimidad Social | `img/legitimidad.png` |
| 4 | Legitimidad Social | `img/jp_legitimidad.png` |
| 5 | Justicia Procedimental | Dos columnas: definición |
| 6 | Presentación de estudios | ESEP, EPSEP, financiamiento |
| 7–17–11–13 | Cuatro observaciones (x4) | Cada vez se resalta una observación en **bold**, las demás en `.grey` |
| 8 | Eficacia | `img/efficacy_crime_bars.png` |
| 9 | Justicia Proc. | `img/jp.png` |
| 10 | Legitimidad | `img/legitimidad.png` |
| 12 | JP y legitimidad | `img/p3_legitimidad_x_justicia_proc.png` |
| 14 | Miedo a Carabineros | `img/emo_pol_fear_bars.png` |
| 15–16 | Miedo y legitimidad | `img/fear1.png`, `img/fear2.png` + footnote EPSEP |
| 18 | Empoderamiento | `img/emp_pol1_bars.png` |
| 19 | Emp. + JP | `img/emp_pol1_x_pj_int1_w06.png` |
| 20 | Emp. + violencia pol. | `img/emp_pol1_x_vio_pol_protest_w06_rec_w06.png` |
| 21 | Conclusiones | Lista de 3 puntos |

### Clases CSS útiles
- `{.grey}` — texto gris claro (observaciones de-enfatizadas)
- `{.footnote}` — nota al pie pequeña (usada en láminas 15–16)
- `{.smaller}` — reduce tamaño de fuente en una lámina (RevealJS nativo)
- `.highlight-box` — caja azul con borde izquierdo teal

### Renderizado
```bash
cd presentation/2026_mesa_redonda
quarto render mesa_redonda.qmd
```

---

## Script de gráficos (`graficos.R`)

Genera 3 gráficos desde `data/esep_w0.rds`:

| Plot | Variable | Grupos | Output |
|------|----------|--------|--------|
| `p1` | `c1_3` (legitimidad) — % "De acuerdo" + "Muy de acuerdo" | sexo, edad_recod, NSE | (no guardado) |
| `p2` | `c2_2` (justicia proc.) — % "Siempre" + "Casi siempre" | sexo, edad_recod, NSE | (no guardado) |
| `p3` | Legitimidad (`c1_3`) por nivel de JP (`c2_2`) | Bajo vs Alto | `img/p3_legitimidad_x_justicia_proc.png` |

**Estilo:** viridis D (begin=0.2, end=0.75), barras con IC 95%, etiquetas `n=` dentro de barras, `theme_esep()` custom.

---

## Datos clave

- **`c1_3`**: Acuerdo con que Carabineros comparte mismos valores. Escala Likert 1–5. Acuerdo = "De acuerdo" + "Muy de acuerdo" (o "Muy de Acuerdo" — hay inconsistencia de capitalización en las etiquetas).
- **`c2_2`**: Frecuencia con que Carabineros trata a personas con respeto. Escala frecuencia. Alto = "Casi siempre" + "Siempre".
- **`ponderador`**: Variable de ponderación muestral (siempre usar en `wt=` o `sum(ponderador[...])`).
- **`edad_recod`**: 18–34, 35–54, 55+ años (recodificada de `edad_encuestado`).
- **`gse_recod`**: ABC1, C2/C3, E/D (recod. desde variable `gse`; valor 7 = NA).
- **`sexo`**: convertir con `to_label(sexo)` → "Hombre" / "Mujer".

---

## Paletas de colores del proyecto

```r
# Viridis usada en graficos.R
scale_fill_viridis_d(option = "D", begin = 0.2, end = 0.75)

# Paletas manuales en index.qmd
palette_oles_6 <- c("#fde725","#7ad151","#2a788e","#414487","#440154","grey")
```

## Colores del tema CSS
- Dark navy: `#1B3A4B`
- Teal: `#2a788e`
- Yellow accent: `#fde725`
- Grey text: `#2d3748`
