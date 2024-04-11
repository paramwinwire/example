name: Unit Test via Pytest

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10"]

    steps:
      - uses: actions/checkout@v3
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
      - name: Install pytest
        run: pip install pytest
      - name: Install coverage package
        run: pip install coverage
      - name: Lint with Ruff
        run: |
          pip install ruff
          ruff --format=github --target-version=py310 .
        continue-on-error: true
      - name: Test with pytest and generate JUnit XML report
        run: |
          coverage run -m pytest --junitxml=pytest-report.xml -v -s
      - name: Upload Test Results
        uses: actions/upload-artifact@v2
        with:
          name: test-results
          path: pytest-report.xml

      - name: Generate Coverage Report
        run: |
          coverage report -m
