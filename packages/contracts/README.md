# Contracts

The shared contracts of Smart Surveillance System. openapi.json is the OpenAPI 3.1 document of the API, generated from the running application and committed so clients can generate code and check compatibility without starting the API. The root README describes the product.

## Run

Regenerate the document after any change to the API routes or schemas:

```
scripts/export-openapi.sh
```

The script imports the API in a throwaway uv container and writes packages/contracts/openapi.json, or the path given as its first argument.

## Test

The API test test_openapi.py checks the document the application produces. Run the API suite as services/api/README.md describes, then regenerate this file and confirm git shows no unintended difference.

## Configuration

| Item | Default | Meaning |
|---|---|---|
| Output path | packages/contracts/openapi.json | First argument of scripts/export-openapi.sh |
