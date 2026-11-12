.PHONY: api-dev api-test web-dev

api-dev:
	cd services/api && ENV=dev uvicorn mb_api.main:app --reload --port 3013

api-test:
	cd services/api && python -m pytest

web-dev:
	cd apps/web && npm run dev

.PHONY: install test-scripts agents-check

install:
	pip install -r requirements-dev.txt

test-scripts:
	pytest -q tests

agents-check:
	python scripts/validate_agents.py
