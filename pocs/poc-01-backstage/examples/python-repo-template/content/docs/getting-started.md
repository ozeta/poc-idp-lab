# Getting Started

## Prerequisites

- Python `${{ values.pythonVersion }}`
- pip

## Installation

```bash
# Clone the repository
git clone <repo-url>
cd ${{ values.name }}

# Create virtual environment
python${{ values.pythonVersion }} -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Running the Application

```bash
python -m ${{ values.name }}
```

## Running Tests

```bash
pip install pytest
pytest
```

## Project Structure

```
${{ values.name }}/
├── docs/               # TechDocs documentation
├── src/                # Application source code
├── tests/              # Test files
├── requirements.txt    # Python dependencies
├── mkdocs.yml          # TechDocs configuration
└── catalog-info.yaml   # Backstage catalog descriptor
```
