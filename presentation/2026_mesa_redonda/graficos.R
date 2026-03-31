pacman::p_load(
  tidyverse, haven, labelled, sjlabelled,
  viridis, scales, janitor
)

# ── Datos ──────────────────────────────────────────────────────────────────────
data_ola0 <- readRDS("../../data/esep_w0.rds") |>
  janitor::clean_names() |>
  rename(edad = edad_encuestado) |>
  mutate(
    edad_recod = case_when(
      edad <= 34             ~ "18-34 años",
      edad > 34 & edad <= 54 ~ "35-54 años",
      edad > 54              ~ "55 años o más"
    ),
    gse_recod = case_when(
      gse %in% c(6, 5) ~ "E/D",
      gse %in% c(4, 3)  ~ "C2/C3",
      gse %in% c(2, 1)  ~ "ABC1",
      gse == 7           ~ NA_character_
    ),
    sexo = to_label(sexo)
  )

val_label(data_ola0$c1_3, 99) <- "NS-NR"
val_label(data_ola0$c1_3, 88) <- "NS-NR"
val_label(data_ola0$c2_2, 99) <- "NS-NR"
val_label(data_ola0$c2_2, 88) <- "NS-NR"

# Etiquetas positivas
labels_acuerdo  <- c("De acuerdo", "Muy de acuerdo", "Muy de Acuerdo")
labels_alto_c22 <- c("Casi siempre", "Siempre")

# ── Tema base ──────────────────────────────────────────────────────────────────
theme_esep <- function(base_size = 14) {
  theme_classic(base_size = base_size) +
    theme(
      legend.position      = "none",
      axis.title.x         = element_blank(),
      axis.title.y         = element_text(size = base_size - 1),
      axis.text.x          = element_text(size = base_size - 2),
      axis.text.y          = element_text(size = base_size - 2),
      strip.text           = element_text(size = base_size - 1, face = "bold"),
      strip.background     = element_blank(),
      plot.title           = element_text(size = base_size, face = "bold"),
      plot.caption         = element_text(size = 9, hjust = 1, color = "grey40"),
      panel.grid.major.y   = element_line(color = "grey90", linewidth = 0.4),
      panel.grid.major.x   = element_blank()
    )
}

# ── Función auxiliar: proporción con IC 95% por grupo ─────────────────────────
pct_grupo <- function(data, grupo_var, grupo_label, var_label_col, positivo) {
  data |>
    drop_na({{ grupo_var }}) |>
    group_by(grupo = as.character({{ grupo_var }})) |>
    summarise(
      n    = n(),
      prop = sum(ponderador[{{ var_label_col }} %in% positivo], na.rm = TRUE) /
             sum(ponderador, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      se    = sqrt(prop * (1 - prop) / n),
      ci_lo = pmax(0, prop - qnorm(0.975) * se),
      ci_hi = pmin(1, prop + qnorm(0.975) * se),
      dimension = grupo_label
    )
}

# ── GRÁFICO 1 ─ Legitimidad (c1_3) por grupos sociales ────────────────────────

d <- data_ola0 |> mutate(c1_3_lbl = to_label(c1_3))

g1_data <- bind_rows(
  pct_grupo(d, sexo,       "Sexo", c1_3_lbl, labels_acuerdo),
  pct_grupo(d, edad_recod, "Edad", c1_3_lbl, labels_acuerdo),
  pct_grupo(d, gse_recod,  "NSE",  c1_3_lbl, labels_acuerdo)
) |>
  mutate(
    dimension = factor(dimension, levels = c("Sexo", "Edad", "NSE")),
    grupo = factor(grupo, levels = c(
      "Hombre", "Mujer",
      "18-34 años", "35-54 años", "55 años o más",
      "ABC1", "C2/C3", "E/D"
    ))
  )

p1 <- ggplot(g1_data, aes(x = grupo, y = prop, fill = grupo)) +
  geom_col(width = 0.55, alpha = 0.92) +
  geom_errorbar(
    aes(ymin = ci_lo, ymax = ci_hi),
    width = 0.18, linewidth = 0.7, color = "grey25"
  ) +
  geom_text(
    aes(label = scales::percent(prop, accuracy = 0.1), y = ci_hi),
    vjust = -0.5, size = 4.5, fontface = "bold", color = "grey20"
  ) +
  geom_text(
    aes(label = paste0("n=", scales::comma(n)), y = 0.01),
    vjust = 0, size = 3.4, color = "white", fontface = "bold"
  ) +
  facet_wrap(~dimension, scales = "free_x") +
  scale_fill_viridis_d(option = "D", begin = 0.2, end = 0.75, guide = "none") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.10),
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    title   = "Legitimidad de Carabineros en distintos grupos sociales",
    y       = "% de acuerdo o muy de acuerdo",
    caption = "Fuente: Estudio de Percepciones de Seguridad y Policías en Chile (ESEP 2023-2024)"
  ) +
  theme_esep()

# ── GRÁFICO 2 ─ Justicia en el trato (c2_2) por grupos sociales ───────────────

d2 <- data_ola0 |> mutate(c2_2_lbl = to_label(c2_2))

g2_data <- bind_rows(
  pct_grupo(d2, sexo,       "Sexo", c2_2_lbl, labels_alto_c22),
  pct_grupo(d2, edad_recod, "Edad", c2_2_lbl, labels_alto_c22),
  pct_grupo(d2, gse_recod,  "NSE",  c2_2_lbl, labels_alto_c22)
) |>
  mutate(
    dimension = factor(dimension, levels = c("Sexo", "Edad", "NSE")),
    grupo = factor(grupo, levels = c(
      "Hombre", "Mujer",
      "18-34 años", "35-54 años", "55 años o más",
      "ABC1", "C2/C3", "E/D"
    ))
  )

p2 <- ggplot(g2_data, aes(x = grupo, y = prop, fill = grupo)) +
  geom_col(width = 0.55, alpha = 0.92) +
  geom_errorbar(
    aes(ymin = ci_lo, ymax = ci_hi),
    width = 0.18, linewidth = 0.7, color = "grey25"
  ) +
  geom_text(
    aes(label = scales::percent(prop, accuracy = 0.1), y = ci_hi),
    vjust = -0.5, size = 4.5, fontface = "bold", color = "grey20"
  ) +
  geom_text(
    aes(label = paste0("n=", scales::comma(n)), y = 0.01),
    vjust = 0, size = 3.4, color = "white", fontface = "bold"
  ) +
  facet_wrap(~dimension, scales = "free_x") +
  scale_fill_viridis_d(option = "D", begin = 0.2, end = 0.75, guide = "none") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.10),
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    title   = "Percepcion de justicia en el trato en distintos grupos sociales",
    y       = "% siempre o casi siempre",
    caption = "Fuente: Estudio de Percepciones de Seguridad y Policías en Chile (ESEP 2023-2024)"
  ) +
  theme_esep()

# ── GRÁFICO 3 ─ Legitimidad (c1_3) según niveles de justicia proc. (c2_2) ──────

g3_data <- data_ola0 |>
  mutate(
    c1_3_lbl = to_label(c1_3),
    c2_2_lbl = to_label(c2_2),
    justicia_proc = case_when(
      c2_2_lbl %in% c("Nunca", "Pocas veces", "Algunas veces") ~
        "Baja",
      c2_2_lbl %in% c("Casi siempre", "Siempre") ~
        "Alta"
    )
  ) |>
  drop_na(justicia_proc) |>
  group_by(justicia_proc) |>
  summarise(
    n    = n(),
    prop = sum(ponderador[c1_3_lbl %in% labels_acuerdo], na.rm = TRUE) /
           sum(ponderador, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    se    = sqrt(prop * (1 - prop) / n),
    ci_lo = pmax(0, prop - qnorm(0.975) * se),
    ci_hi = pmin(1, prop + qnorm(0.975) * se),
    justicia_proc = factor(justicia_proc, levels = c(
      "Baja",
      "Alta"
    ))
  )

p3 <- ggplot(g3_data, aes(x = justicia_proc, y = prop, fill = justicia_proc)) +
  geom_col(width = 0.45, alpha = 0.92) +
  geom_errorbar(
    aes(ymin = ci_lo, ymax = ci_hi),
    width = 0.12, linewidth = 0.8, color = "grey25"
  ) +
  geom_text(
    aes(label = scales::percent(prop, accuracy = 0.1), y = ci_hi),
    vjust = -0.6, size = 5.5, fontface = "bold", color = "grey20"
  ) +
  geom_text(
    aes(label = paste0("n=", scales::comma(n)), y = 0.01),
    vjust = 0, size = 4, color = "white", fontface = "bold"
  ) +
  scale_fill_viridis_d(option = "D", begin = 0.2, end = 0.75, guide = "none") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.10),
    expand = expansion(mult = c(0, 0.14))
  ) +
  labs(
    title   = "Legitimidad de Carabineros según justicia procedimental",
    y       = "% de acuerdo o muy de acuerdo",
    caption = "Fuente: Estudio de Percepciones de Seguridad y Policías en Chile (ESEP 2023-2024)"
  ) +
  theme_esep(base_size = 15)

ggsave("p3_legitimidad_x_justicia_proc.png", plot = p3,
       width = 8, height = 6, dpi = 180, bg = "white")

# ── Imprimir ───────────────────────────────────────────────────────────────────
print(p1)
print(p2)
print(p3)
