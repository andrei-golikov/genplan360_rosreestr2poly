# Rosreestr → GeoJSON → polygon.json → krpano XML

Этот документ — **практический гайд** по обработке участков из Росреестра.

## 1) Выгрузка из Росреестра

Мы используем CLI `rosreestr2coord` (или совместимый инструмент). Базовая команда:

```bash
rosreestr2coord -c <КАДАСТРОВЫЙ_НОМЕР_ИЛИ_КВАРТАЛ> -o data/geojson/<имя>.geojson
```

**Фильтры (как ты хотел в проекте):**
- Кадастровый квартал
- Кадастровый номер «центрального» участка
- Максимальное расстояние от центра
- Дата постановки на кадастровый учёт
- Мин/макс площадь

> Логика фильтров реализуется на уровне предобработки/постобработки JSON — см. раздел «Фильтрация».

Проверяем результат: в `data/geojson/` должны появиться файлы `*.geojson`,
где **каждый участок — Polygon** с координатами в EPSG:3857 (или lon/lat с полем CRS).

## 2) Быстрая визуализация

Чтобы убедиться, что геометрия читается, используем `get_pic.py`:

```bash
python tools/get_pic.py --src data/geojson --out data/outputs/output_raw.png
```

## 3) Базовый пайплайн (двухэтапный)

Скрипт `get2Dplot_good.py` выполняет:

1. **Черновой `polygon.json`** — участки + разметочная сетка (без трансформации).
2. **Ручной ввод 4 контрольных квадратов** (имена клеток, а не координаты) → вычисляется аффинная матрица.
3. **Финальный `polygon.json`** — только участки Росреестра, **трансформированные** по матрице.

Вызываем:

```bash
python tools/get2Dplot_good.py --src data/geojson --out data/outputs/polygon.json
```

## 4) Точная подстройка (опционально)

Если нужно дополнительно поправить масштаб/смещение/угол **без** пересчёта матрицы —
`manual_adjust_polygon_good_twistedaxis.py`:

```bash
python tools/manual_adjust_polygon_good_twistedaxis.py --in data/outputs/polygon.json --out data/outputs/polygon.adjusted.json
# Скрипт интерактивно спросит масштаб (по умолчанию 1), dx, dy и угол (градусы).
```

## 5) Экспорт для krpano

Полный конвейер `get_pic_and_hotspots_result_json_complete.py`

- Читает `.geojson` и формирует:
  - XML с hotspot’ами (полигоны/полилинии) для krpano,
  - `result.json` (метаданные участков).
- Поддерживает «плоский» интерактивный генплан и рендер PNG «вид сверху» для контроля.

Пример:

```bash
python tools/get_pic_and_hotspots_result_json_complete.py \  --src data/geojson \  --out-xml krpano/hs01.xml \  --out-json data/outputs/result.json \  --camera-height 100
```

## 6) Нормализация/переименование hotspot’ов

```bash
# Единообразные имена (hs00001 и т.д.)
python tools/normalize_hotspot_names.py --in krpano/hs01.xml --out krpano/hs01.normalized.xml

# Массовые ручные замены по словарю
python tools/rename_hotspots.py --in krpano/hs02.xml --map replacements.txt --out krpano/hs02.renamed.xml
```

---

## Фильтрация участков (примерная логика)

После выгрузки `.geojson` фильтруем свойства `Feature.properties`:

- `label` — полный кадастровый номер;
- `area` — площадь участка;
- `registration_date` — дата постановки на учёт.

Псевдокод:

```python
def filter_features(features, center_cadastr=None, max_radius_m=None, area_min=None, area_max=None, date_min=None):
    # 1) при необходимости — находим центр по cadastral id и считаем расстояния в метрах (EPSG:3857)
    # 2) применяем поочерёдно все заданные фильтры
    return [f for f in features if pass_all_filters(f)]
```

---

## Результирующие файлы

- `data/outputs/output_raw.png` — первичная визуализация.
- `data/outputs/polygon.json` — финальный набор участков для интеграции.
- `krpano/hs01.xml` — hotspot’ы для тура.
- `data/outputs/result.json` — сопутствующие метаданные.