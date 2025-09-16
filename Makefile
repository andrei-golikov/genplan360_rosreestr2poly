# ========== Настройки ==========
PY=python
VENV=.venv
SRC_DIR=data/geojson
OUT_DIR=data/outputs
TOOLS_DIR=tools
KRPANO_DIR=krpano

# Примеры параметров
CAD_NUM?=47:23:0424002
HEIGHT?=100

# ========== Виртуальное окружение ==========
.PHONY: venv
venv:
	$(PY) -m venv $(VENV)

.PHONY: deps
deps:
	. $(VENV)/bin/activate && pip install -U pip matplotlib shapely pyproj

# ========== Шаги пайплайна ==========
.PHONY: fetch
fetch:
	@mkdir -p $(SRC_DIR)
	rosreestr2coord -c $(CAD_NUM) -o $(SRC_DIR)/$(subst :,_,$(CAD_NUM)).geojson

.PHONY: visualize
visualize:
	@mkdir -p $(OUT_DIR)
	$(PY) $(TOOLS_DIR)/get_pic.py --src $(SRC_DIR) --out $(OUT_DIR)/output_raw.png

.PHONY: pipeline
pipeline:
	@mkdir -p $(OUT_DIR)
	$(PY) $(TOOLS_DIR)/get2Dplot_good.py --src $(SRC_DIR) --out $(OUT_DIR)/polygon.json

.PHONY: manual-adjust
manual-adjust:
	$(PY) $(TOOLS_DIR)/manual_adjust_polygon_good_twistedaxis.py --in $(OUT_DIR)/polygon.json --out $(OUT_DIR)/polygon.adjusted.json

.PHONY: hotspots
hotspots:
	@mkdir -p $(OUT_DIR) $(KRPANO_DIR)
	$(PY) $(TOOLS_DIR)/get_pic_and_hotspots_result_json_complete.py --src $(SRC_DIR) --out-xml $(KRPANO_DIR)/hs01.xml --out-json $(OUT_DIR)/result.json --camera-height $(HEIGHT)

.PHONY: xml-normalize
xml-normalize:
	$(PY) $(TOOLS_DIR)/normalize_hotspot_names.py --in $(KRPANO_DIR)/hs01.xml --out $(KRPANO_DIR)/hs01.normalized.xml

.PHONY: xml-rename
xml-rename:
	$(PY) $(TOOLS_DIR)/rename_hotspots.py --in $(KRPANO_DIR)/hs02.xml --map replacements.txt --out $(KRPANO_DIR)/hs02.renamed.xml
