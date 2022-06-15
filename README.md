# TP2 Orga2

## Como generar csv para experimentacion de Broken?
1. Implementacion original
    - Hacer make.
    - Correr src/experimentos/brokenCsv.sh
2. CLFLUSH
    - Descomentar los clflush de la implementación original.
    - Hacer make.
    - Correr src/experimentos/brokenFlush.sh
3. Por columnas
    - Comentar toda la implementacion original.
    - Descomentar la implementacion por columnas.
    - Hacer make.
    - Correr src/experimentos/brokenColsCsv.sh

Estos 3 pasos dejan en broken.csv todos los resultados para luego procesarlos y graficar con brokenByCols.ipynb


Integrantes:
 - Pablo Lopes Perera
 - Joaquin Naftaly (@joaconafta)
 - Gabriel Hayon (@gabrielhayon)
