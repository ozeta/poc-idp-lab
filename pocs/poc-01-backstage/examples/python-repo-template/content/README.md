# ${{ values.name }}

${{ values.description }}

## Getting Started

### Prerequisites

- Python `${{ values.pythonVersion }}`
- pip (or your preferred package manager)

### Setup

1. Create a virtual environment:

   ```bash
   python${{ values.pythonVersion }} -m venv .venv
   source .venv/bin/activate
   ```

2. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. Run the application:

   ```bash
   python -m ${{ values.name }}
   ```

## Documentation

This project includes [TechDocs](https://backstage.io/docs/features/techdocs/) for Backstage.
To preview docs locally:

```bash
pip install mkdocs mkdocs-material
mkdocs serve
```

## Ownership

Owner: `${{ values.owner }}`
