# Plan de Pruebas QA - NoDebuffNoLoot v2.4.1

Este documento establece un marco exhaustivo para verificar la estabilidad y el correcto funcionamiento del addon tras las recientes auditorías de bases de datos y ajustes en la lógica de asignación.

## Fase 1: Verificación de Datos y Rastreo (Core Data)

El objetivo de esta fase es confirmar que la auditoría de IDs funciona perfectamente en el rastreador de combate del addon.

- `[ ]` **Test SP-1 (Habilidades Base)**: Asigna "Sunder Armor", "Hunter's Mark" y "Faerie Fire" en el panel. Entra en combate y aplica los perjuicios al objetivo. Revisa que el HUD ponga los iconos en verde.
- `[ ]` **Test SP-2 (Habilidades de Talento)**: Asigna "Winter's Chill", "Shadow Weaving" y "Mangle". Golpea a un objetivo con estas magias o habilidades. Verifica que el HUD detecte la vulnerabilidad resultante y ponga los iconos en verde.
- `[ ]` **Test SP-3 (Hechizos de Paladín)**: Asigna "Judgement of Light", "Wisdom" y "Crusader". Usa sentencias de paladín (con el respectivo sello activado). El HUD debe reconocer y ponerse en verde.
- `[ ]` **Test SP-4 (Mascotas de Cazador)**: Asigna "Screech". Haz que la mascota (Murciélago/Búho) ataque. Verifica que el HUD lo detecte.

## Fase 2: Inteligencia de Asignación y Talentos (SmartValidation)

Verifica que el Addon recomiende e inspeccione correctamente a los miembros de la banda.

- `[ ]` **Test SV-1 (Sugerencias Inteligentes)**: Forma un grupo con una clase específica (ej. un Pícaro). Añade una fila nueva en Asignaciones. Al hacer clic en el menú desplegable del hechizo, "Exponer armadura" debería aparecer priorizado. 
- `[ ]` **Test SV-2 (Violación de Clase)**: En una fila, elige "Tormenta de truenos" (Chamán) y asigna como Primario a un Pícaro. Debería aparecer un ícono rojo `!` al lado del nombre advirtiendo que la clase es incorrecta.
- `[ ]` **Test SV-3 (Validación de Talentos - El Bug Solucionado)**: Elige "Exponer armadura mejorada" y asigna a un Pícaro que **no** tiene el talento. Debería aparecer el ícono `!` de advertencia. Si asignas a un pícaro que **sí** tiene el talento (verificando la inspección), el ícono `!` debería desaparecer.
- `[ ]` **Test SV-4 (Excepción Sunder/Expose)**: Asigna "Sunder Armor" a un Guerrero. Entra en combate. Haz que un pícaro (no asignado) aplique "Expose Armor". "Sunder Armor" en el HUD ya no debería brillar en rojo (satisfecho silenciosamente).

## Fase 3: Interfaz de Gestión (ConfigUI)

Pruebas en la usabilidad y diseño del panel principal (`/ndnl`).

- `[ ]` **Test UI-1 (Arrastrar y Soltar)**: Mueve las filas de asignaciones creadas de arriba hacia abajo usando los botones de flechas para reordenar las prioridades. El HUD en pantalla debe actualizarse de inmediato para reflejar el orden.
- `[ ]` **Test UI-2 (Autocompletado)**: Empieza a escribir el nombre de un jugador del grupo en la casilla Primario/Secundario. Debe aparecer un menú autocompletando su nombre.
- `[ ]` **Test UI-3 (Retraso en Combate)**: Edita el valor bajo la columna "Delay" (por ejemplo: `8` segundos) y comprueba que se guarda correctamente entre sesiones.

## Fase 4: Comportamiento del HUD de Rastreo (Tracker HUD)

Verificar cómo se desenvuelven los gráficos del rastreador principal durante el estado de combate.

- `[ ]` **Test HUD-1 (Estados Visuales)**:
  - Objetivo Deseleccionado/Amistoso: Iconos deben estar atenuados (Gris / IDLE).
  - Inicio de combate a Enemigo: El borde debe volverse amarillo o pulsar suavemente durante el "Delay" asignado en la Fase 3 (PENDING).
  - Vencimiento del Delay: Si el hechizo aún no está, los fondos y bordes del icono se vuelven rojos llamativos (MISSING).
- `[ ]` **Test HUD-2 (Filtro de Jefes)**: En Opciones, activa "Solo en Jefes". Verifica que el HUD desaparece o se oculta si seleccionas enemigos comunes (no élites élite/calavera).
- `[ ]` **Test HUD-3 (Filtro Personal)**: En opciones, activa "Solo Mis Asignaciones". El HUD solo debe mostrarte los iconos en los que tú fuiste puesto como Primario o Suplente.
- `[ ]` **Test HUD-4 (Ocultar Satisfechos)**: En opciones, activa "Mostrar Solo Faltantes". El icono de un debuff aplicado debería desaparecer en vez de volverse verde.

## Fase 5: Alertas y Sincronización a la Banda

Asegurar que las notificaciones intrusivas funcionen según lo ajustado, y que los clientes reciban las misiones.

- `[ ]` **Test AL-1 (Aviso a Raid)**: Como líder del grupo, haz clic en "Anunciar a Raid" en el panel.
  - La Raid debe recibir una Advertencia de Banda (Raid Warning) en su pantalla con la lista principal.
  - Los jugadores asignados deben recibir un mensaje de `Susurro (Whisper)` privado con sus deberes.
- `[ ]` **Test AL-2 (Sincronización en red)**: Modifica una designación o hechizo siendo líder. Automáticamente, tu amigo/alter (asistente) que tenga la misma versión del addon instalada deberá ver cómo su panel `/ndnl` se actualiza en tiempo real, reflejando tus cambios.
- `[ ]` **Test AL-3 (Restricción de Privilegios)**: Intenta modificar una celda del panel o enviar un `Anunciar a Raid` mientras estás con rango de miembro normal en una banda. El addon debería negarte la acción o no propagar el cambio al archivo de la banda.
- `[ ]` **Test AL-4 (Pantalla Flash Azul/Roja o Audio)**: Deja vencer el temporizador "Delay" de una de tus asignaciones maestras en combate. Verifica que la pantalla parpadee visiblemente y se emita el sonido acústico de advertencia indicando que fallaste.
