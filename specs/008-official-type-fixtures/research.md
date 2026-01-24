# Research: Official Type Definition Format Support

**Feature**: 008-official-type-fixtures
**Date**: 2026-01-24

## Official ECMA-427 Type Definition Schema Analysis

### Schema Structure

The official purl-spec type definitions follow a standardized JSON schema. Key fields analyzed:

```json
{
  "$schema": "https://packageurl.org/schemas/purl-type-definition.schema-1.0.json",
  "$id": "https://packageurl.org/types/{type}-definition.json",
  "type": "string",           // Required: type identifier (e.g., "pypi", "cargo")
  "type_name": "string",      // Display name (e.g., "PyPI", "Cargo")
  "description": "string",    // Human-readable description

  "name_definition": {
    "requirement": "required|optional|prohibited",
    "case_sensitive": true|false,    // Key field for normalization
    "native_name": "string",
    "normalization_rules": ["string"],  // Human-readable rules
    "note": "string"
  },

  "namespace_definition": {
    "requirement": "required|optional|prohibited",
    "case_sensitive": true|false,
    "native_name": "string"
  },

  "version_definition": {
    "requirement": "required|optional",
    "case_sensitive": true|false,
    "native_name": "string"
  },

  "qualifiers_definition": [
    {
      "key": "string",
      "requirement": "required|optional",
      "description": "string",
      "native_name": "string",
      "default_value": "string"
    }
  ],

  "examples": ["string"]
}
```

### Normalization Rule Mapping

**Decision**: Map official schema fields to internal normalization operations.

| Official Field | Condition | Internal Operation |
|----------------|-----------|-------------------|
| `name_definition.case_sensitive` | `false` | `"lowercase"` |
| `normalization_rules[]` | Contains "underscore" AND "dash" | `"replace_underscore"` |
| `normalization_rules[]` | Contains "dot" AND ("dash" OR "hyphen") | `"replace_dot"` |

**Rationale**: The official schema uses `case_sensitive: false` to indicate lowercase normalization, while `normalization_rules` contains human-readable text. Pattern matching on keywords provides reliable extraction.

**Alternatives considered**:
1. **Exact string matching**: Rejected - rules vary in wording across definitions
2. **Regular expressions**: Rejected - over-engineering for simple keyword detection
3. **Manual mapping per type**: Rejected - doesn't scale to 47+ types

### Qualifier Extraction

**Decision**: Parse `qualifiers_definition` array to populate known/required qualifiers.

| Official Field | Condition | Internal Field |
|----------------|-----------|----------------|
| `qualifiers_definition[].key` | Always | `known_qualifiers` |
| `qualifiers_definition[].requirement` | `"required"` | `required_qualifiers` |

**Rationale**: Direct mapping from official schema structure.

### Type-Specific Observations

#### PyPI (pypi-definition.json)
- `name_definition.case_sensitive: false` → lowercase
- `normalization_rules: ["Replace underscore _ with dash -"]` → replace_underscore
- `qualifiers_definition: [{key: "file_name", requirement: "optional"}]`

#### Cargo (cargo-definition.json)
- `name_definition.case_sensitive: true` → NO lowercase
- No `normalization_rules` → no additional normalization
- No `qualifiers_definition` → empty qualifier lists

#### Maven (maven-definition.json)
- `name_definition.case_sensitive: true` → NO lowercase
- `qualifiers_definition` with classifier and type (both optional)

#### npm (npm-definition.json)
- `name_definition.case_sensitive: false` → lowercase
- `namespace_definition.case_sensitive: false` → namespace also lowercased
- Note mentions lowercase requirement in package.json spec

### Format Detection

**Decision**: Detect official vs simplified format by checking for `name_definition` key.

```julia
is_official_format = haskey(json, :name_definition)
```

**Rationale**: The `name_definition` key is unique to official format and always present when `name` requirements exist. Simplified format uses `name.normalize` instead.

**Alternative considered**: Check for `$schema` key. Rejected because it's optional in valid JSON files.

### Edge Cases

1. **No `name_definition`**: Use empty normalization (case-sensitive by default)
2. **No `normalization_rules`**: Only apply case_sensitive rule
3. **Unrecognized rule patterns**: Skip silently for forward compatibility
4. **No `qualifiers_definition`**: Empty known/required lists

## Implementation Approach

**Decision**: Update `load_type_definition()` with internal helper functions.

```julia
function load_type_definition(path::AbstractString)
    # ... existing file reading ...

    # Detect format
    is_official = haskey(json, :name_definition)

    if is_official
        _parse_official_format!(json, name_normalize, required_qualifiers, known_qualifiers)
    end
    # Note: No else branch - simplified format support removed per user request

    return TypeDefinition(...)
end

function _parse_official_format!(json, name_normalize, required_qualifiers, known_qualifiers)
    # Parse name_definition
    if haskey(json, :name_definition)
        name_def = json[:name_definition]
        if get(name_def, :case_sensitive, true) == false
            push!(name_normalize, "lowercase")
        end
        # Parse normalization_rules for patterns
    end

    # Parse qualifiers_definition
    if haskey(json, :qualifiers_definition)
        for qual in json[:qualifiers_definition]
            push!(known_qualifiers, String(qual[:key]))
            if get(qual, :requirement, "optional") == "required"
                push!(required_qualifiers, String(qual[:key]))
            end
        end
    end
end
```

**Rationale**: Helper function keeps main function clean. Pattern-based extraction handles variation in human-readable rules.

## Test Strategy

1. Copy official definitions from `data/type_definitions/` to `test/fixtures/type_definitions/`
2. Test each type loads without error
3. Verify normalization rules extracted correctly (pypi has lowercase+replace_underscore, cargo has none)
4. Verify qualifiers extracted correctly (maven has classifier+type)
5. Integration test: load official definition, register, parse PURL, verify normalization applied
