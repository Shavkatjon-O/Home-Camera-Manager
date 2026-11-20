import { defineConfig, globalIgnores } from "eslint/config"
import jsdoc from "eslint-plugin-jsdoc"
import nextVitals from "eslint-config-next/core-web-vitals"
import nextTs from "eslint-config-next/typescript"

export default defineConfig([
  ...nextVitals,
  ...nextTs,
  {
    files: ["**/*.ts", "**/*.tsx"],
    plugins: { jsdoc },
    settings: { jsdoc: { mode: "typescript" } },
    rules: {
      "jsdoc/require-jsdoc": [
        "error",
        {
          publicOnly: true,
          require: {
            FunctionDeclaration: true,
            ArrowFunctionExpression: true,
            ClassDeclaration: true,
            MethodDefinition: true,
          },
          contexts: ["ExportNamedDeclaration > VariableDeclaration", "TSInterfaceDeclaration", "TSTypeAliasDeclaration"],
        },
      ],
      "jsdoc/require-description": "error",
      "jsdoc/check-param-names": "error",
      "jsdoc/check-tag-names": "error",
      "jsdoc/no-types": "error",
      "jsdoc/require-returns-description": "error",
      "jsdoc/require-param-description": "error",
    },
  },
  globalIgnores([".next/**", "out/**", ".source/**", "generated/**", "next-env.d.ts"]),
])
