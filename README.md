# Ari: Los Ecos que Dejamos

RPG de terror psicológico en pixel art, al estilo de *Mad Father* y *Misao*, hecho en **Godot 4.7**.

Edd vuelve de noche a la Universidad Tecnológica Valle Niebla (nombre ficticio) para recoger las cosas de Ari. Cada objeto que encuentra abre un recuerdo y revela una parte de la verdad.

## Cómo abrirlo

1. Abre Godot 4.7.2 → **Importar** → selecciona `project.godot`.
2. Pulsa **F5**.

## Controles

| Acción | Teclas |
|---|---|
| Moverse (por casillas) | Flechas o WASD |
| Examinar / avanzar diálogo | Z, E, Espacio o Enter |
| Objetos | X, TAB o I |
| Pausa | Esc |

## Qué tiene

- **Vista RPG desde arriba**, con movimiento por casillas y personajes animados en 4 direcciones.
- **Retratos grandes con emociones** junto al texto. Edd aparece a la izquierda y los demás a la derecha.
- **7 mapas** inspirados en las fotos de la universidad: auditorio con "BIENVENIDOS", pasillo con paredes durazno y piso cerámico, aula B-204 con sillas verdes, rosas y negras, biblioteca, bodega de mantenimiento, dirección y azotea con vista a la cancha y al bosque.
- **Ambiente**: luces de techo que parpadean, linterna alrededor de Edd, lluvia, relámpagos y apariciones de Ari fantasma. Los recuerdos felices se ven en sepia y los dolorosos en rojo.
- **14 capítulos, minijuegos, 3 finales y epílogo**: los mismos del guion.

### Emociones disponibles

Se escriben en el diálogo como `"Ari:triste"`. Si una emoción no existe, se usa `neutral`.

| Personaje | Emociones |
|---|---|
| Ari | neutral, feliz, rie, triste, llora, miedo, enojada, sombra, sonrojada |
| Edd | neutral, feliz, triste, llora, miedo, enojado, serio |
| Damián | neutral, burla, enojado, miedo |
| Vera | neutral, burla, enojada, miedo |
| Nico | neutral, triste, miedo, llora |
| Rivas | neutral, sombra, enojado, serio |
| Claudia | neutral, triste, llora, feliz |

## De dónde sale el arte

- **Ari**: tu pixel art original (resolución nativa 140×196). Las emociones están dibujadas pixel por pixel encima.
- **Edd**: recortado y pixelado de `Nina y Nino.jpg`, más emociones dibujadas.
- **Damián, Vera, Nico, Rivas y Claudia**: generados con el generador de imágenes de Canva (están en tu cuenta de Canva), pixelados y con emociones dibujadas. Se acabaron los créditos de Canva después de 5 imágenes. Por eso Helena Duarte no tiene retrato; en el guion nunca habla.
- **Sprites para caminar** (24×32, 4 direcciones): dibujados por código en `tools/sprites.py`.
- **Mapas**: tileset de 16×16 dibujado por código en `tools/maps.py`, basado en las fotos.

## Profesores reales (cameos)

Hay dos cameos genéricos: el profesor de guardia del capítulo 1 y el profesor de la clase en el recuerdo del capítulo 2. Hoy no se parecen a nadie y se llaman "Prof. de guardia" y "Profesor". **Pon un nombre o rasgos reales solo si esa persona dio su permiso.** Los nombres se cambian en `scripts/Story.gd` (`PROFE_GUARDIA`, `PROFE_CLASE`) y el aspecto en `tools/sprites.py` (`profe1`, `profe2`).

Rivas, Helena y los acosadores son personajes inventados y no deben basarse en personas reales.

## Regenerar o modificar el arte

Requiere Python con `pillow`, `numpy` y `scipy`.

```
python tools/emotions.py   # retratos con emociones  -> assets/portraits/
python tools/sprites.py    # sprites para caminar    -> assets/chars/
python tools/maps.py       # mapas + colisiones      -> assets/maps/
```

- **Cambiar un mapa**: edita `build_maps()` en `tools/maps.py` (paredes, puertas, muebles, zonas para examinar y luces). Al correrlo se regeneran el PNG del mapa y `maps.json` con las colisiones.
- **Agregar emociones**: en `tools/emotions.py`, cada personaje tiene las coordenadas de ojos y boca; agrega la emoción a su lista `emo`.
- **Usar arte hecho a mano**: reemplaza los PNG de `assets/portraits/`, `assets/chars/` o `assets/maps/` respetando los tamaños.

## Estructura

```
assets/portraits/  Retratos con emociones
assets/chars/      Hojas de sprites para caminar (3×4 cuadros de 24×32)
assets/maps/       Mapas pre-renderizados, capa superior y maps.json (colisiones, puertas, zonas)
assets/images/     Fotografía (con y sin figuras ocultas)
scripts/Main.gd    Motor: mapa, cámara, UI, transiciones, efectos
scripts/Story.gd   Toda la historia y los diálogos
scripts/world/     Map, Character (personajes), Player (Edd), lluvia
scripts/ui/        Diálogo con retratos, opciones, teléfono, inventario, título, epílogo
scripts/minigames/ Lupa, candado, peluche, diario UV, línea temporal
tools/             Scripts de Python que generan el arte
```

<details>
<summary>Soluciones (spoilers)</summary>

- **Candado**: 1403 (14 de marzo, la fecha del listón).
- **Peluche**: voltéalo y haz clic en la costura.
- **Fotografía**: con la lupa, revisa el fondo a la izquierda (hay 3 figuras).
- **Cuchillo**: responde "Las fechas no encajan".
- **Diario**: necesitas la linterna UV del casillero de Ari.
- **Final verdadero**: los 8 objetos y las 4 pistas ocultas.
</details>
