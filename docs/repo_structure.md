# Рекомендуемая структура репозитория и версияция

```
genplan360/
  data/
    geojson/           # выгрузка из Росреестра (.geojson)
    outputs/           # все картинки/итоги пайплайна
  krpano/
    hs01.xml
    hs02.xml
    actions.xml
    tour.xml
  tools/
    kad_coord.py
    get_pic.py
    get2Dplot_good.py
    manual_adjust_polygon_good_twistedaxis.py
    get_pic_and_hotspots_result_json_complete.py
    round_polygon_coordinates_digit_groups.py
    normalize_hotspot_names.py
    rename_hotspots.py
  docs/
    rosreestr_pipeline.md
    repo_structure.md
  Makefile
  README.md
```

## Версионирование и сопровождение веток

- Основная ветка: `main` — **рабочий стабильный** пайплайн.
- Для изменений по конкретной версии: ветки `release/x.y` (например, `release/1.0`, `release/1.1`).  
  - Хотим обновить эндпоинт **во всех поддерживаемых** релизах — делаем отдельные PR в каждую `release/x.y`.
  - Из `main` регулярно делаем **backport** нужных фиксов с помощью `git cherry-pick` в релизные ветки.
- Теги: `v1.0.0`, `v1.1.0`, ... — помечают **точные сборки**.
- Правило PR: в описание добавлять чек-лист затронутых скриптов и `Makefile` таргетов.

Совет: автоматизировать тестовый прогон (`make pipeline`) на CI с фикстурами `examples/*.geojson`.