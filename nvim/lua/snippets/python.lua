local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node

local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Snippet original: snippet b "Python block"
  s("b", {
    t("# %% "),
    i(0)
  }, {
    description = "Python block separator"
  }),
  --
  -- matplotlib.pyplot good
  s("mpl", {
    t([[
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from tools.matplotlib.style import apply_style
    apply_style()
    ]]),
    i(0)
  }, {
    description = "Matplotlib configuration charger"
  }),
  --
  -- Main function con docstring
  s("main", fmt([[
  def main() -> None:
      """{}"""
      {}

  if __name__ == "__main__":
      main()
  ]], {
    i(1, "Función principal"),
    i(2, "# Tu código aquí")
  }), {
    description = "Estructura main con docstring"
  }),

  -- Función con type hints completos
  s("def", fmt([[
  def {}({}) -> {}:
      """{}"""
      {}
  ]], {
    i(1, "function_name"),
    i(2, "args"),
    i(3, "None"),
    i(4, "Descripción de la función"),
    i(5, "pass")
  }), {
    description = "Función con type hints y docstring"
  }),

  -- Clase con docstring y __init__
  s("class", fmt([[
  class {}:
      """{}"""

      def __init__(self{}):
          """Constructor."""
          {}
  ]], {
    i(1, "ClassName"),
    i(2, "Descripción de la clase"),
    i(3, ""),
    i(4, "self.attr = value")
  }), {
    description = "Clase con docstring y constructor"
  }),

  -- Property con getter y setter
  s("prop", fmt([[
  @property
  def {}(self) -> {}:
      """{}"""
      return self._{}

  @{}.setter
  def {}(self, {}: {}) -> None:
      """{}"""
      self._{} = {}
  ]], {
    i(1, "property_name"),
    i(2, "type"),
    i(3, "Descripción del property"),
    rep(1),  -- Repite property_name para self._property_name
    rep(1),  -- Para el decorador @property_name.setter
    rep(1),  -- Para el nombre del setter
    i(4, "value"),  -- Nombre del parámetro
    i(5, "type"),   -- Tipo del parámetro
    i(6, "Setter description"),  -- Docstring del setter
    rep(1),  -- Para self._property_name
    rep(4)   -- Para el valor
  }), {
    description = "Property con getter y setter"
  }),

  -- Test con pytest
  s("test", fmt([[
  def test_{}() -> None:
      """Test {}."""
      # Arrange
      {}
      
      # Act
      {}
      
      # Assert
      assert {}
  ]], {
    i(1, "function_name"),
    rep(1),  -- Repite el nombre para el docstring
    i(2, "# Preparar datos"),
    i(3, "# Ejecutar función"),
    i(4, "expected == actual")
  }), {
    description = "Test con estructura AAA (Arrange-Act-Assert)"
  }),

  -- Dataclass
  s("dc", fmt([[
  @dataclass
  class {}:
      """{}"""
      {}: {}
      {}
  ]], {
    i(1, "ClassName"),
    i(2, "Descripción de la clase"),
    i(3, "field"),
    i(4, "type"),
    i(0)  -- Campos adicionales
  }), {
    description = "Dataclass con type hints"
  }),

  -- Try/except con múltiples excepciones
  s("try", {
    t("try:"),
    t({ "", "    " }),
    i(1, "# Código a intentar"),
    t({ "", "except " }),
    c(2, {
      t("Exception as e"),
      t("ValueError as e"),
      t("TypeError as e"),
      t("KeyError as e"),
      t("FileNotFoundError as e")
    }),
    t({ ":", "    " }),
    i(3, "print(f'Error: {e}')"),
    t({ "", "finally:", "    " }),
    i(4, "# Código de limpieza")
  }, {
    description = "Try/except/finally completo"
  }),

  -- With statement para recursos
  s("with", fmt([[
  with {} as {}:
      {}
  ]], {
    i(1, "open('file.txt', 'r')"),
    i(2, "f"),
    i(3, "content = f.read()")
  }), {
    description = "With statement para manejo de recursos"
  }),

  -- List comprehension
  s("lc", fmt("[{} for {} in {}]", {
    i(1, "x"),
    i(2, "x"),
    i(3, "iterable")
  }), {
    description = "List comprehension básica"
  }),

  -- Dictionary comprehension
  s("dictc", fmt("{{{}: {} for {} in {}}}", {
    i(1, "key"),
    i(2, "value"),
    i(3, "item"),
    i(4, "iterable")
  }), {
    description = "Dictionary comprehension"
  }),

  -- Lambda function
  s("lambda", fmt("lambda {}: {}", {
    i(1, "x"),
    i(2, "x")
  }), {
    description = "Lambda function"
  }),

  -- Imports comunes
  s("imp", {
    c(1, {
      t("import numpy as np"),
      t("import pandas as pd"),
      t("import matplotlib.pyplot as plt"),
      t("from typing import "),
      t("from pathlib import Path"),
      t("from dataclasses import dataclass"),
      t("import json"),
      t("import csv"),
      t("import sys"),
      t("import os")
    }),
    i(0)
  }, {
    description = "Import común de Python"
  }),

  -- Decorator
  s("deco", fmt([[
  def {}(func):
      """{}"""
      @wraps(func)
      def wrapper(*args, **kwargs):
          {}
          result = func(*args, **kwargs)
          {}
          return result
      return wrapper
  ]], {
    i(1, "decorator_name"),
    i(2, "Descripción del decorador"),
    i(3, "# Código antes de ejecutar la función"),
    i(4, "# Código después de ejecutar la función")
  }), {
    description = "Decorador con functools.wraps"
  }),

  -- Async function
  s("async", fmt([[
  async def {}({}) -> {}:
      """{}"""
      {}
  ]], {
    i(1, "function_name"),
    i(2, ""),
    i(3, "None"),
    i(4, "Función asíncrona"),
    i(5, "await asyncio.sleep(1)")
  }), {
    description = "Función asíncrona"
  }),

  -- Match statement (Python 3.10+)
  s("match", fmt([[
  match {}:
      case {}:
          {}
      case _:
          {}
  ]], {
    i(1, "value"),
    i(2, "pattern"),
    i(3, "# handle pattern"),
    i(4, "# default case")
  }), {
    description = "Match statement (Python 3.10+)"
  }),

  -- Logger setup
  s("log", fmt([[
  import logging

  # Configurar logger
  logging.basicConfig(
      level=logging.{},
      format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
      datefmt="%Y-%m-%d %H:%M:%S"
  )

  logger = logging.getLogger(__name__)
  ]], {
    c(1, {
      t("DEBUG"),
      t("INFO"),
      t("WARNING"),
      t("ERROR")
    })
  }), {
    description = "Configuración básica de logging"
  }),

  -- Context manager personalizado
  s("ctx", fmt([[
  class {}:
      """{}"""

      def __enter__(self):
          {}
          return {}

      def __exit__(self, exc_type, exc_val, exc_tb):
          {}
          return False  # No suprimir excepciones
  ]], {
    i(1, "ContextManager"),
    i(2, "Context manager personalizado"),
    i(3, "# Código al entrar al contexto"),
    i(4, "self"),
    i(5, "# Código al salir del contexto")
  }), {
    description = "Context manager personalizado"
  }),

  -- F-string con formato
  s("fstr", fmt('f"{}"', {
    i(1, "{variable:,.2f}")
  }), {
    description = "F-string con formato"
  }),

  -- Type alias
  s("type", fmt([[
  {} = {}
  ]], {
    i(1, "Vector"),
    i(2, "list[float]")
  }), {
    description = "Type alias"
  }),

  -- Enum
  s("enum", fmt([[
  class {}(Enum):
      """{}"""
      {} = {}
      {}
  ]], {
    i(1, "Color"),
    i(2, "Colores disponibles"),
    i(3, "RED"),
    i(4, "1"),
    i(0)
  }), {
    description = "Enumeration"
  }),

  -- =========================================================================
  -- SNIPPETS ESPECÍFICOS PARA TU WORKFLOW
  -- =========================================================================
  
  -- Header para archivos Python (como tu AutoHeaderPy)
  s("header", {
    f(function()
      local filename = vim.fn.expand("%:t")
      local date = os.date("%a %d. %b %Y")
      return string.format([[
#!/usr/bin/env python3

# =============================================================================
# Author:       %s
# Contact:      %s
# Created:      %s
#
# Purpose:      %s
# =============================================================================
]], os.getenv("USER") or "Your Name", 
   os.getenv("EMAIL") or "your.email@example.com", 
   date, 
   "Descripción del propósito")
    end),
    t({ "", "", "def main() -> None:", "    pass", "", "" }),
    i(0)
  }, {
    description = "Header para archivos Python"
  }),

  -- Test header (como tu AutoHeaderTestPy)
  s("testheader", {
    f(function()
      local filename = vim.fn.expand("%:t")
      local date = os.date("%a %d. %b %Y")
      local module = filename:gsub("test_", ""):gsub(".py", "")
      return string.format([[
#!/usr/bin/env python3

# =============================================================================
# Author:       %s
# Contact:      %s
# Created:      %s
#
# Purpose:      Test for %s
# =============================================================================
]], os.getenv("USER") or "Your Name", 
   os.getenv("EMAIL") or "your.email@example.com", 
   date, 
   module)
    end),
    t({ "", "", "import pytest", "", "" }),
    i(0)
  }, {
    description = "Header para tests"
  }),

  -- Quarto/Magma cell con título
  s("cell", {
    t("# %% [markdown]"),
    t({ "", "# # " }),
    i(1, "Cell Title"),
    t({ "", "", "# %%", "" }),
    i(0)
  }, {
    description = "Celda Quarto/Magma con markdown"
  }),

  -- Docstring Google style
  s("doc", fmt([[
  """{}.

  {}
  
  Args:
      {}: {}.
  
  Returns:
      {}: {}.
  
  Raises:
      {}: {}.
  """
  ]], {
    i(1, "Descripción breve"),
    i(2, "Descripción detallada"),
    i(3, "param"),
    i(4, "descripción del parámetro"),
    i(5, "valor"),
    i(6, "descripción del retorno"),
    i(7, "Exception"),
    i(8, "cuándo se lanza")
  }), {
    description = "Docstring estilo Google"
  }),

  -- Docstring Numpy style
  s("docnumpy", fmt([[
  """{}
  
  Parameters
  ----------
  {} : {}
      {}
  
  Returns
  -------
  {} : {}
      {}
  """
  ]], {
    i(1, "Descripción"),
    i(2, "parameter"),
    i(3, "type"),
    i(4, "description"),
    i(5, "value"),
    i(6, "type"),
    i(7, "description")
  }), {
    description = "Docstring estilo Numpy"
  })
}
