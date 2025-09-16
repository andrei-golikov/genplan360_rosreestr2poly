# Генплан360 — Rosreestr Pipeline (starter pack)

Набор файлов, который поможет **быстро развернуть и поддерживать** часть проекта,
связанную с получением участков из Росреестра и их преобразованием для последующей
визуализации и интеграции в krpano / интерактивный генплан.

## 🎯 Цели

- Единый, понятный **плейбук**: от выгрузки участков → до `polygon.json` и XML hotspot’ов.
- Документация и шпаргалки — чтобы **через полгода** не вспоминать «что за скрипт и где он был».
- Готовые команды (`Makefile`) для повторяемого запуска.

---

## 📦 Состав

- `docs/rosreestr_pipeline.md` — подробный гайд по работе с Росреестром (CLI, фильтры, пайплайн).
- `docs/repo_structure.md` — рекомендуемая структура репо и принципы версионирования.
- `scripts/rosreestr_cli_cheatsheet.md` — короткая шпаргалка по `rosreestr2coord`.
- `Makefile` — удобные цели: `fetch`, `visualize`, `pipeline`, `manual-adjust`, `hotspots`, `xml-normalize`, `xml-rename`.
- `examples/polygon_sample.json` — пример финального JSON с участками.

> Примечание: сами рабочие скрипты (например, `get2Dplot_good.py`, `get_pic_and_hotspots_result_json_complete.py`)
у тебя уже есть в основном проекте — здесь мы даём **обвязку, инструкции и стандарты**.

---

## 🚀 Быстрый старт

1) Установи зависимости:
```bash
python -m venv .venv && . .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -U pip
# Если используешь Python-скрипты визуализации:
pip install matplotlib shapely pyproj
# Для Rosreestr CLI:
# https://github.com/kolypto/rosreestr2coord (или твой форк/зеркало)
```

2) Проверь, что `rosreestr2coord` виден из командной строки:
```bash
rosreestr2coord --help
```

3) Отредактируй переменные в `Makefile` под свой кейс: `CAD_NUM`, `OUTDIR`, `HEIGHT`, пути к скриптам.

4) Запусти пайплайн (пример):
```bash
make fetch            # выгрузка .geojson
make visualize        # быстрая картинка с полигонами
make pipeline         # черновой polygon.json -> калибровка 4 точками -> финальный polygon.json
make manual-adjust    # при необходимости подкрутить масштаб/смещения/угол
make hotspots         # сформировать XML hotspot’ы и result.json
```

---

## 📁 Рекомендуемая структура репозитория

Смотри `docs/repo_structure.md`, кратко:

```
genplan360/
  data/geojson/                 # выгруженные исходники из Росреестра
  data/outputs/                 # картинки, промежуточные и финальные JSON
  krpano/                       # hs01.xml, hs02.xml, actions.xml, tour.xml
  tools/                        # твои Python-скрипты (из основного проекта)
  docs/                         # документация
  Makefile
  README.md
```

---

## 🔧 Скрипты проекта (кратко)

| Скрипт                                 | Назначение |
|----------------------------------------|------------|
| `kad_coord.py`                         | Выгрузка участков из Росреестра (через `rosreestr2coord`) в `.geojson` |
| `get_pic.py`                           | Быстрая визуализация geojson → `output.png` |
| `get2Dplot_good.py`                    | Двухэтапный пайплайн: черновой `polygon.json` + ручная трансформация по 4 квадратам |
| `manual_adjust_polygon_good_twistedaxis.py` | Ручная подстройка `polygon.json` (масштаб, смещение, угол) |
| `get_pic_and_hotspots_result_json_complete.py` | Полный конвейер: geojson → hotspot XML + `result.json` |
| `round_polygon_coordinates_digit_groups.py` | Экспериментальная «шумилка/округлялка» координат в `polygon.json` |
| `normalize_hotspot_names.py`           | Приведение имён hotspot’ов к формату `hs00001` |
| `rename_hotspots.py`                   | Массовое переименование hotspot’ов по словарю замен |

Полные описания и примеры — в `docs/rosreestr_pipeline.md`.